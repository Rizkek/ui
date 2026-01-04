import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'app_detection_service.dart';
import 'screen_capture_service.dart';
import '../../constants/api_constants.dart';
import '../widgets/nsfw_alert_screen.dart';

/// AutoScreenshotService - Service untuk auto capture setiap 5 detik
/// 
/// FUNGSI:
/// 1. Timer otomatis setiap 5 detik
/// 2. Capture FULL SCREEN (bukan cuma app Flutter)
/// 3. Detect app yang sedang dibuka
/// 4. Save ke folder dengan filename: screenshot_[time]_[appname].png
/// 5. Track semua screenshot dalam list
class AutoScreenshotService extends GetxController {
  // Service untuk detect app name
  final AppDetectionService _appDetectionService = AppDetectionService();

  // Service untuk capture FULL SCREEN (MediaProjection)
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  // Timer untuk loop 5 detik
  Timer? _timer;

  // Observable variables untuk UI update
  final RxBool isRecording = false.obs;
  final RxInt screenshotCount = 0.obs;
  final RxString currentApp = 'Unknown'.obs;
  final RxList<Map<String, dynamic>> screenshots = <Map<String, dynamic>>[].obs;
  
  // Observable untuk trigger notifikasi NSFW
  final Rx<NsfwDetection?> latestNsfwDetection = Rx<NsfwDetection?>(null);

  // Path folder untuk session ini
  String? _sessionFolder;

  /// START - Mulai auto screenshot setiap 5 detik
  /// 
  /// FLOW:
  /// 1. Request MediaProjection permission (popup system)
  /// 2. User klik "Start now"
  /// 3. Buat folder untuk session ini
  /// 4. Capture screenshot pertama
  /// 5. Start timer untuk capture tiap 5 detik
  Future<void> startAutoScreenshot() async {
    if (isRecording.value) return;

    // STEP 1: Request permission untuk capture full screen
    print('🔑 Requesting screen capture permission...');
    bool permissionGranted = await _screenCaptureService.startCapture();

    if (!permissionGranted) {
      Get.snackbar(
        'Permission Denied',
        'Anda harus mengizinkan screen capture untuk melanjutkan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    print('✅ Permission granted! Setting up monitoring...');

    // STEP 2: Buat folder untuk session ini
    await _createSessionFolder();

    // STEP 3: Reset counters
    isRecording.value = true;
    screenshotCount.value = 0;
    screenshots.clear();

    // STEP 4: Wait for warm-up (native side does dummy capture ~1.2s)
    // Give a safe buffer so first real capture succeeds on most devices
    print('⏳ Waiting ~1.5s for VirtualDisplay warm-up...');
    await Future.delayed(const Duration(milliseconds: 1500));

    // STEP 5: Start timer untuk capture setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _captureAndSave();
    });

    // STEP 6: Capture pertama
    print('📸 Starting first actual capture...');
    await _captureAndSave();

    Get.snackbar(
      'Recording Started ✅',
      'Screenshot akan diambil setiap 5 detik',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// STOP - Hentikan auto screenshot
  /// 
  /// FLOW:
  /// 1. Cancel timer
  /// 2. Stop MediaProjection
  /// 3. Show summary
  Future<void> stopAutoScreenshot() async {
    // Cancel timer
    _timer?.cancel();
    _timer = null;

    // Stop screen capture
    await _screenCaptureService.stopCapture();

    isRecording.value = false;

    Get.snackbar(
      'Recording Stopped ⏹️',
      'Total ${screenshotCount.value} screenshot disimpan di:\n$_sessionFolder',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  /// CAPTURE - Ambil 1 screenshot, kirim ke API /detectnsfw
  /// 
  /// FLOW:
  /// 1. Detect app yang sedang dibuka (UsageStatsManager)
  /// 2. Capture full screen frame (MediaProjection)
  /// 3. Kirim ke API dengan JWT token
  /// 4. Simpan hasil ke list (in-memory)
  Future<void> _captureAndSave() async {
    try {
      // STEP 1: Deteksi aplikasi yang sedang dibuka
      String appName = await _appDetectionService.getCurrentApp();
      currentApp.value = appName;
      print('📱 Current app: $appName');

      // STEP 2: Capture FULL SCREEN - langsung tanpa wait
      final Uint8List? imageBytes = await _screenCaptureService.captureFrame();

      if (imageBytes == null) {
        print(
          '! No frame available yet - VirtualDisplay might still be initializing',
        );
        print('   Will retry in 5 seconds...');
        return;
      }

      if (imageBytes.isEmpty) {
        print('⚠️ Captured image is empty');
        return;
      }

      // STEP 3: Increment counter
      screenshotCount.value++;

      // STEP 4: Kirim ke API /detectnsfw
      final nsfwLevel = await _sendToDetectNsfwApi(imageBytes, appName);
      
      if (nsfwLevel != null) {
        // STEP 5: Simpan ke memory jika API call berhasil
        screenshots.add({
          'timestamp': DateTime.now(),
          'app_name': appName,
          'image_bytes': imageBytes,
          'size': imageBytes.length,
          'api_sent': true,
          'nsfw_level': nsfwLevel,
        });

        print('✅ Screenshot #${screenshotCount.value} captured and sent to API');
        print('   📱 App: $appName');
        print('   📦 Size: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB');
        print('   🔍 NSFW Level: $nsfwLevel');

        // STEP 6: Trigger notifikasi jika level 1, 2, atau 3
        if (nsfwLevel > 0) {
          latestNsfwDetection.value = NsfwDetection(
            level: nsfwLevel,
            appName: appName,
            timestamp: DateTime.now(),
          );
          print('🚨 NSFW detected! Triggering alert...');
        }
      } else {
        print('⚠️ Screenshot captured but API call failed');
        // Tetap simpan tapi tandai sebagai failed
        screenshots.add({
          'timestamp': DateTime.now(),
          'app_name': appName,
          'image_bytes': imageBytes,
          'size': imageBytes.length,
          'api_sent': false,
          'nsfw_level': null,
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error capturing screenshot: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// SEND TO API - Kirim screenshot ke /api/detectnsfw
  /// 
  /// PARAMS:
  /// - imageBytes: Screenshot dalam format PNG (Uint8List)
  /// - appName: Nama aplikasi yang sedang dibuka
  /// 
  /// RETURN:
  /// - int (0-3) jika berhasil dan dapat response dari API
  /// - null jika gagal
  Future<int?> _sendToDetectNsfwApi(Uint8List imageBytes, String appName) async {
    try {
      // STEP 1: Get JWT token dari Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        print('❌ User not logged in, cannot send to API');
        return null;
      }

      String? idToken = await currentUser.getIdToken();
      
      if (idToken == null) {
        print('❌ Failed to get ID token');
        return null;
      }

      print('🔐 JWT Token obtained');

      // STEP 2: Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.detectNsfw),
      );

      // STEP 3: Add JWT token to headers
      request.headers['Authorization'] = 'Bearer $idToken';

      // STEP 4: Add image file (PNG)
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name sesuai backend
          imageBytes,
          filename: 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );

      // STEP 5: Add application name as text field
      request.fields['application'] = appName;

      print('📤 Sending to API: ${ApiUrls.detectNsfw}');
      print('   📱 Application: $appName');
      print('   📦 Image size: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB');

      // STEP 6: Send request dengan timeout 30 detik
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ API request timeout (30s)');
          throw TimeoutException('Request timeout');
        },
      );

      // STEP 7: Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ API call successful: ${response.statusCode}');
        print('   Response: ${response.body}');
        
        // STEP 8: Parse response untuk ambil nsfw_level
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final int nsfwLevel = responseData['nsfw_level'] ?? 0;
          print('   📊 Parsed NSFW Level: $nsfwLevel');
          return nsfwLevel;
        } catch (e) {
          print('⚠️ Failed to parse response: $e');
          return null;
        }
      } else {
        print('❌ API call failed: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('❌ API timeout: $e');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error sending to API: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// Buat folder untuk session ini
  Future<void> _createSessionFolder() async {
    try {
      // Get external storage directory
      Directory? externalDir = await getExternalStorageDirectory();

      if (externalDir == null) {
        print('❌ External storage not available');
        return;
      }

      // Buat folder dengan nama tanggal dan waktu
      String sessionName = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      String basePath = '${externalDir.path}/Paradise_Screenshots';
      _sessionFolder = '$basePath/$sessionName';

      Directory sessionDir = Directory(_sessionFolder!);
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }

      print('📁 Session folder created: $_sessionFolder');
    } catch (e) {
      print('❌ Error creating session folder: $e');
    }
  }

  /// Get folder path saat ini
  String? getSessionFolder() {
    return _sessionFolder;
  }

  /// Clear semua data
  void clear() {
    screenshots.clear();
    screenshotCount.value = 0;
    currentApp.value = 'Unknown';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

/// NsfwDetection - Model untuk data deteksi NSFW
/// 
/// Digunakan untuk trigger notifikasi full-screen
class NsfwDetection {
  final int level; // 0-3
  final String appName;
  final DateTime timestamp;

  NsfwDetection({
    required this.level,
    required this.appName,
    required this.timestamp,
  });
}
