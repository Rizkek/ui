import 'package:flutter/services.dart';
import 'dart:typed_data';

/// ScreenCaptureService - Service untuk capture full screen
/// 
/// FUNGSI:
/// 1. Request MediaProjection permission
/// 2. Capture screenshot FULL SCREEN (termasuk app lain)
/// 3. Return image sebagai Uint8List (byte array)
/// 
/// CARA KERJA:
/// - Menggunakan MethodChannel untuk komunikasi dengan native code (Kotlin)
/// - Native code menggunakan MediaProjection API Android
/// - Image dikembalikan dalam format PNG
class ScreenCaptureService {
  // Channel untuk komunikasi dengan native code
  static const platform = MethodChannel('com.paradise.app/screen_capture');

  // Status apakah capture sedang aktif
  bool _isCapturing = false;

  /// Getter untuk cek status capturing
  bool get isCapturing => _isCapturing;

  /// STEP 1: Request permission dan start capture
  /// 
  /// FLOW:
  /// 1. Flutter call method 'startCapture'
  /// 2. Native (Kotlin) show system dialog
  /// 3. User klik "Start now"
  /// 4. Native setup MediaProjection
  /// 5. Return true/false ke Flutter
  /// 
  /// @return true jika user approve, false jika deny
  Future<bool> startCapture() async {
    try {
      print('🚀 ScreenCaptureService: Requesting capture permission...');

      // Call native method dengan timeout 30 detik
      final bool? granted = await platform.invokeMethod('startCapture').timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ ScreenCaptureService: Permission request timeout!');
          return false;
        },
      );

      if (granted == true) {
        _isCapturing = true;
        print('✅ ScreenCaptureService: Permission granted! Capture started.');
        return true;
      } else {
        _isCapturing = false;
        print('❌ ScreenCaptureService: Permission denied by user.');
        return false;
      }
    } on PlatformException catch (e) {
      print('❌ ScreenCaptureService: Platform error: ${e.message}');
      print('   Code: ${e.code}, Details: ${e.details}');
      _isCapturing = false;
      return false;
    } catch (e) {
      print('❌ ScreenCaptureService: Unexpected error: $e');
      _isCapturing = false;
      return false;
    }
  }

  /// STEP 2: Capture frame - LANGSUNG tanpa wait
  /// 
  /// @return Uint8List image data (PNG), atau null jika belum ready
  Future<Uint8List?> captureFrame() async {
    if (!_isCapturing) {
      print('⚠️ ScreenCaptureService: Capture not started yet!');
      return null;
    }

    try {
      // LANGSUNG capture tanpa wait
      final Uint8List? imageBytes = await platform.invokeMethod('captureFrame');

      if (imageBytes != null) {
        final sizeKB = imageBytes.length / 1024;
        print(
            '✅ ScreenCaptureService: Frame captured! Size: ${sizeKB.toStringAsFixed(2)} KB');
        return imageBytes;
      } else {
        print(
            '⚠️ ScreenCaptureService: No frame available (VirtualDisplay might be initializing)');
        return null;
      }
    } on PlatformException catch (e) {
      print('❌ ScreenCaptureService: Platform error: ${e.message}');
      return null;
    } catch (e) {
      print('❌ ScreenCaptureService: Unexpected error: $e');
      return null;
    }
  }

  /// STEP 3: Stop capture dan cleanup
  /// 
  /// FLOW:
  /// 1. Flutter call method 'stopCapture'
  /// 2. Native release MediaProjection
  /// 3. Free memory dan resources
  Future<void> stopCapture() async {
    if (!_isCapturing) {
      print('⚠️ ScreenCaptureService: Capture already stopped');
      return;
    }

    try {
      print('⏹️ ScreenCaptureService: Stopping capture...');

      // Call native method untuk stop
      await platform.invokeMethod('stopCapture');

      _isCapturing = false;
      print('✅ ScreenCaptureService: Capture stopped successfully');
    } on PlatformException catch (e) {
      print('❌ ScreenCaptureService: Error stopping: ${e.message}');
      _isCapturing = false;
    } catch (e) {
      print('❌ ScreenCaptureService: Unexpected error: $e');
      _isCapturing = false;
    }
  }
}
