import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/risk_detection.dart';
import '../models/parent_settings.dart';
import '../services/monitoring/content_trigger_service.dart';
import '../views/widgets/content_block_popup.dart';
import '../views/screens/education/psychoeducation_screen.dart';

/// Controller untuk manajemen deteksi konten dan popup blocking
class DetectionController extends GetxController {
  // Observable states
  final parentSettings = Rx<ParentSettings?>(null);
  final detectionHistory = <RiskDetection>[].obs;
  final currentDetection = Rx<RiskDetection?>(null);
  final isMonitoring = false.obs;
  final detectedToday = 0.obs;
  final blockedToday = 0.obs;

  // Statistics by risk level
  final highRiskCount = 0.obs;
  final mediumRiskCount = 0.obs;
  final lowRiskCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadParentSettings();
    _loadDetectionHistory();
    _startMonitoring();
  }

  /// Load parent settings dari storage/database
  Future<void> _loadParentSettings() async {
    try {
      // TODO: Load dari SharedPreferences atau Supabase
      // Untuk sekarang, gunakan default settings
      parentSettings.value = ParentSettings(
        userId: 'current_user_id',
        isParentModeEnabled: true,
        pin: '1234', // Default PIN
        blockPopupEnabled: true,
        highRiskAutoBlock: true,
        mediumRiskNotify: true,
        lowRiskWarning: true,
      );

      debugPrint('✅ Parent settings loaded');
    } catch (e) {
      debugPrint('❌ Error loading parent settings: $e');
    }
  }

  /// Load detection history
  Future<void> _loadDetectionHistory() async {
    try {
      // TODO: Load dari database
      // Untuk sekarang gunakan empty list
      detectionHistory.clear();
      _updateStatistics();

      debugPrint(
        '✅ Detection history loaded: ${detectionHistory.length} items',
      );
    } catch (e) {
      debugPrint('❌ Error loading detection history: $e');
    }
  }

  /// Start monitoring service
  void _startMonitoring() {
    isMonitoring.value = true;
    debugPrint('🔍 Detection monitoring started');
  }

  /// Stop monitoring service
  void stopMonitoring() {
    isMonitoring.value = false;
    debugPrint('⏸️ Detection monitoring stopped');
  }

  /// Handle konten terdeteksi
  Future<void> handleDetection({
    required String appName,
    required String packageName,
    String? textContent,
    String? url,
    BuildContext? context,
  }) async {
    if (!isMonitoring.value) return;

    try {
      // Detect content using trigger service
      final detection = await ContentTriggerService.detectContent(
        appName: appName,
        packageName: packageName,
        textContent: textContent,
        url: url,
      );

      if (detection == null) return;

      // Update current detection
      currentDetection.value = detection;

      // Add to history
      detectionHistory.insert(0, detection);
      if (detectionHistory.length > 100) {
        detectionHistory.removeLast(); // Keep max 100 items
      }

      // Update statistics
      _updateStatistics();

      // Save to database
      await _saveDetection(detection);

      // Handle berdasarkan risk level dan parent settings
      await _handleByRiskLevel(detection, context);
    } catch (e) {
      debugPrint('❌ Error handling detection: $e');
    }
  }

  /// Handle detection berdasarkan risk level
  Future<void> _handleByRiskLevel(
    RiskDetection detection,
    BuildContext? context,
  ) async {
    final settings = parentSettings.value;

    switch (detection.riskLevel) {
      case RiskLevel.high:
        // HIGH RISK - Auto block + Popup
        if (settings?.highRiskAutoBlock == true) {
          blockedToday.value++;

          if (settings?.blockPopupEnabled == true && context != null) {
            await _showBlockPopup(detection, context);
          }

          // Send urgent notification to parent
          await _sendParentNotification(detection, isUrgent: true);
        }
        break;

      case RiskLevel.medium:
        // MEDIUM RISK - Warning + Notification
        if (settings?.mediumRiskNotify == true) {
          if (settings?.blockPopupEnabled == true && context != null) {
            await _showBlockPopup(detection, context);
          }

          // Send notification to parent
          await _sendParentNotification(detection);
        }
        break;

      case RiskLevel.low:
        // LOW RISK - Warning saja
        if (settings?.lowRiskWarning == true && context != null) {
          _showLowRiskWarning(detection, context);
        }
        break;
    }
  }

  /// Show block popup untuk high/medium risk
  Future<void> _showBlockPopup(
    RiskDetection detection,
    BuildContext context,
  ) async {
    await ContentBlockPopup.show(
      context: context,
      detection: detection,
      parentSettings: parentSettings.value,
      onPsychoeducationTap: () {
        Get.to(() => PsychoeducationScreen(detection: detection));
      },
      onPinEntered: (pin) async {
        await _handlePinOverride(detection, pin);
      },
    );
  }

  /// Show warning untuk low risk
  void _showLowRiskWarning(RiskDetection detection, BuildContext context) {
    Get.snackbar(
      'Peringatan',
      'Konten yang Anda akses mungkin tidak pantas. Harap berhati-hati.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.yellow.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          Get.to(() => PsychoeducationScreen(detection: detection));
        },
        child: const Text(
          'Pelajari',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Handle PIN override
  Future<void> _handlePinOverride(RiskDetection detection, String pin) async {
    try {
      // Log PIN override
      debugPrint('🔓 Detection disabled via PIN for: ${detection.appName}');

      // Update detection as not blocked
      final index = detectionHistory.indexWhere((d) => d.id == detection.id);
      if (index != -1) {
        detectionHistory[index] = detection.copyWith(isBlocked: false);
      }

      // Temporarily disable monitoring (e.g., for 1 hour)
      await _temporaryDisableMonitoring(const Duration(hours: 1));

      // Log to database
      await _logPinOverride(detection, pin);
    } catch (e) {
      debugPrint('❌ Error handling PIN override: $e');
    }
  }

  /// Temporary disable monitoring
  Future<void> _temporaryDisableMonitoring(Duration duration) async {
    stopMonitoring();

    Get.snackbar(
      'Deteksi Dinonaktifkan',
      'Monitoring akan aktif kembali dalam ${duration.inHours} jam',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    // Re-enable after duration
    await Future.delayed(duration);
    _startMonitoring();

    Get.snackbar(
      'Deteksi Aktif Kembali',
      'Monitoring konten telah diaktifkan kembali',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Send notification to parent
  Future<void> _sendParentNotification(
    RiskDetection detection, {
    bool isUrgent = false,
  }) async {
    try {
      // TODO: Implement push notification atau email ke parent
      debugPrint(
        '📧 Parent notification sent: ${detection.riskLevel.name} - ${detection.appName}',
      );

      if (isUrgent) {
        debugPrint('🚨 URGENT notification marked');
      }
    } catch (e) {
      debugPrint('❌ Error sending parent notification: $e');
    }
  }

  /// Save detection to database
  Future<void> _saveDetection(RiskDetection detection) async {
    try {
      // TODO: Save to Supabase
      debugPrint('💾 Detection saved: ${detection.id}');
    } catch (e) {
      debugPrint('❌ Error saving detection: $e');
    }
  }

  /// Log PIN override to database
  Future<void> _logPinOverride(RiskDetection detection, String pin) async {
    try {
      // TODO: Log to database for parent review
      debugPrint('📝 PIN override logged: ${detection.id}');
    } catch (e) {
      debugPrint('❌ Error logging PIN override: $e');
    }
  }

  /// Update statistics
  void _updateStatistics() {
    final today = DateTime.now();
    final todayDetections = detectionHistory.where((d) {
      return d.detectedAt.year == today.year &&
          d.detectedAt.month == today.month &&
          d.detectedAt.day == today.day;
    }).toList();

    detectedToday.value = todayDetections.length;
    blockedToday.value = todayDetections.where((d) => d.isBlocked).length;

    highRiskCount.value = todayDetections
        .where((d) => d.riskLevel == RiskLevel.high)
        .length;
    mediumRiskCount.value = todayDetections
        .where((d) => d.riskLevel == RiskLevel.medium)
        .length;
    lowRiskCount.value = todayDetections
        .where((d) => d.riskLevel == RiskLevel.low)
        .length;
  }

  /// Update parent settings
  Future<void> updateParentSettings(ParentSettings settings) async {
    try {
      parentSettings.value = settings;

      // TODO: Save to database
      debugPrint('✅ Parent settings updated');

      Get.snackbar(
        'Berhasil',
        'Pengaturan berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Error updating parent settings: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui pengaturan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Get detections by date range
  List<RiskDetection> getDetectionsByDateRange(DateTime start, DateTime end) {
    return detectionHistory.where((d) {
      return d.detectedAt.isAfter(start) && d.detectedAt.isBefore(end);
    }).toList();
  }

  /// Get detections by risk level
  List<RiskDetection> getDetectionsByRiskLevel(RiskLevel level) {
    return detectionHistory.where((d) => d.riskLevel == level).toList();
  }

  /// Clear history
  Future<void> clearHistory() async {
    try {
      detectionHistory.clear();
      _updateStatistics();

      // TODO: Clear from database
      debugPrint('🗑️ Detection history cleared');

      Get.snackbar(
        'Berhasil',
        'Riwayat deteksi berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Error clearing history: $e');
    }
  }
}
