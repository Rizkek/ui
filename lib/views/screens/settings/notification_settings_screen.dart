import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Controller untuk Notification Settings
class NotificationSettingsController extends GetxController {
  final RxBool _allNotifications = true.obs;
  final RxBool _highRiskOnly = false.obs;
  final RxBool _parentalNotifications = true.obs;
  final RxBool _dailySummary = false.obs;
  final RxBool _soundEnabled = true.obs;
  final RxBool _vibrationEnabled = true.obs;

  bool get allNotifications => _allNotifications.value;
  bool get highRiskOnly => _highRiskOnly.value;
  bool get parentalNotifications => _parentalNotifications.value;
  bool get dailySummary => _dailySummary.value;
  bool get soundEnabled => _soundEnabled.value;
  bool get vibrationEnabled => _vibrationEnabled.value;

  void setAllNotifications(bool value) {
    _allNotifications.value = value;
    // TODO: Save to storage
  }

  void setHighRiskOnly(bool value) {
    _highRiskOnly.value = value;
    // TODO: Save to storage
  }

  void setParentalNotifications(bool value) {
    _parentalNotifications.value = value;
    // TODO: Save to storage
  }

  void setDailySummary(bool value) {
    _dailySummary.value = value;
    // TODO: Save to storage
  }

  void setSoundEnabled(bool value) {
    _soundEnabled.value = value;
    // TODO: Save to storage
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled.value = value;
    // TODO: Save to storage
  }
}

/// Screen untuk Notification Settings
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Notifikasi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Atur preferensi notifikasi kamu',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Detection Alerts
            Text(
              'Alert Deteksi',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => _buildSettingCard(
                icon: Icons.notifications_rounded,
                title: 'Semua Notifikasi',
                description: 'Terima notifikasi untuk semua level risiko',
                value: controller.allNotifications,
                onChanged: (value) {
                  controller.setAllNotifications(value);
                  if (!value) {
                    controller.setHighRiskOnly(false);
                  }
                },
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => _buildSettingCard(
                icon: Icons.warning_rounded,
                title: 'High Risk Only',
                description: 'Hanya terima notifikasi untuk konten High Risk',
                value: controller.highRiskOnly,
                onChanged: controller.allNotifications
                    ? (value) {
                        controller.setHighRiskOnly(value);
                      }
                    : null,
                color: const Color(0xFFEF4444),
                isDisabled: !controller.allNotifications,
              ),
            ),

            const SizedBox(height: 32),

            // Parental Features
            Text(
              'Fitur Orang Tua',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => _buildSettingCard(
                icon: Icons.family_restroom_rounded,
                title: 'Notifikasi untuk Orang Tua',
                description:
                    'Kirim notifikasi ke orang tua saat High Risk terdeteksi',
                value: controller.parentalNotifications,
                onChanged: (value) =>
                    controller.setParentalNotifications(value),
                color: const Color(0xFF8B5CF6),
              ),
            ),

            const SizedBox(height: 32),

            // Summary & Reports
            Text(
              'Ringkasan & Laporan',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => _buildSettingCard(
                icon: Icons.assessment_rounded,
                title: 'Ringkasan Harian',
                description: 'Terima ringkasan aktivitas setiap malam',
                value: controller.dailySummary,
                onChanged: (value) => controller.setDailySummary(value),
                color: const Color(0xFF10B981),
              ),
            ),

            const SizedBox(height: 32),

            // Sound & Vibration
            Text(
              'Suara & Getaran',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => _buildSettingCard(
                icon: Icons.volume_up_rounded,
                title: 'Suara Notifikasi',
                description: 'Aktifkan suara untuk notifikasi',
                value: controller.soundEnabled,
                onChanged: (value) => controller.setSoundEnabled(value),
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => _buildSettingCard(
                icon: Icons.vibration_rounded,
                title: 'Getaran',
                description: 'Aktifkan getaran untuk notifikasi',
                value: controller.vibrationEnabled,
                onChanged: (value) => controller.setVibrationEnabled(value),
                color: const Color(0xFF06B6D4),
              ),
            ),

            const SizedBox(height: 32),

            // Test Notification
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Test Notifikasi',
                    'Ini adalah contoh notifikasi dari Paradise Guardian',
                    backgroundColor: const Color(0xFF3B82F6),
                    colorText: Colors.white,
                    icon: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                    ),
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  'Kirim Test Notifikasi',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool)? onChanged,
    required Color color,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              onChanged: isDisabled ? null : onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
