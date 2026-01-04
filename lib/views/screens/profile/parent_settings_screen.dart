import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/detection_controller.dart';
import '../../../models/parent_settings.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
    if (!Get.isRegistered<DetectionController>()) {
      Get.put(DetectionController());
    }

    final SettingsController controller = Get.find<SettingsController>();
    final DetectionController detectionController =
        Get.find<DetectionController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Pengaturan Mode Orang Tua',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Orang Tua Toggle
            _buildParentModeCard(detectionController),

            const SizedBox(height: 24),

            // PIN Configuration
            _buildPinSection(detectionController, context),

            const SizedBox(height: 24),
            _buildSectionHeader('Konfigurasi Popup Block'),
            const SizedBox(height: 10),

            // Popup Block Settings
            _buildPopupBlockCard(detectionController),

            const SizedBox(height: 24),
            _buildSectionHeader('Pengaturan Risk Level'),
            const SizedBox(height: 10),

            // Risk Level Configuration
            _buildRiskLevelCard(detectionController),

            const SizedBox(height: 24),
            _buildSectionHeader('Fitur Tambahan'),
            const SizedBox(height: 10),

            // Additional Features (dari controller lama)
            Obx(
              () => _buildSwitchTile(
                title: 'Proteksi Otomatis',
                subtitle: 'Blur & blokir konten tidak senonoh secara otomatis',
                value: controller.isProtectionEnabled.value,
                onChanged: controller.toggleProtection,
                icon: Icons.security,
                activeColor: Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            Obx(
              () => _buildSwitchTile(
                title: 'Blokir Media Sosial',
                subtitle: 'Batasi akses ke Instagram, TikTok, dll.',
                value: controller.blockSocialMedia.value,
                onChanged: controller.toggleSocialMediaBlock,
                icon: Icons.block,
                activeColor: Colors.red,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Statistik'),
            const SizedBox(height: 10),

            _buildStatisticsCard(detectionController),
          ],
        ),
      ),
    );
  }

  Widget _buildParentModeCard(DetectionController controller) {
    return Obx(() {
      final settings = controller.parentSettings.value;
      final isEnabled = settings?.isParentModeEnabled ?? false;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                : [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isEnabled ? const Color(0xFF4A90E2) : Colors.grey)
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEnabled ? Icons.shield : Icons.shield_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Orang Tua',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isEnabled ? 'Aktif' : 'Nonaktif',
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    final newSettings =
                        (settings ?? ParentSettings(userId: 'current_user'))
                            .copyWith(isParentModeEnabled: value);
                    controller.updateParentSettings(newSettings);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mode ini mengaktifkan popup block otomatis dan memerlukan PIN untuk menonaktifkan deteksi',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPinSection(
    DetectionController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final settings = controller.parentSettings.value;
      final hasPin = settings?.pin != null && settings!.pin!.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PIN Proteksi'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasPin
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasPin ? Icons.lock : Icons.lock_open,
                        color: hasPin ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPin ? 'PIN Aktif' : 'PIN Belum Diset',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            hasPin
                                ? 'PIN diperlukan untuk override deteksi'
                                : 'Set PIN untuk keamanan tambahan',
                            style: GoogleFonts.raleway(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showSetPinDialog(controller, context, hasPin),
                        icon: Icon(hasPin ? Icons.edit : Icons.add),
                        label: Text(hasPin ? 'Ubah PIN' : 'Set PIN'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          side: const BorderSide(color: Color(0xFF4A90E2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (hasPin) ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          final newSettings = settings!.copyWith(pin: null);
                          controller.updateParentSettings(newSettings);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPopupBlockCard(DetectionController controller) {
    return Obx(() {
      final settings = controller.parentSettings.value;

      return Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  color: const Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Popup Block Otomatis',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: settings?.blockPopupEnabled ?? true,
              onChanged: (value) {
                final newSettings =
                    (settings ?? ParentSettings(userId: 'current_user'))
                        .copyWith(blockPopupEnabled: value);
                controller.updateParentSettings(newSettings);
              },
              title: Text(
                'Aktifkan Popup Block',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Popup akan muncul otomatis saat konten berisiko terdeteksi',
                style: GoogleFonts.raleway(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF4A90E2),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: const Color(0xFF4A90E2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Popup block sudah otomatis, hanya PIN yang bisa diatur',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRiskLevelCard(DetectionController controller) {
    return Obx(() {
      final settings = controller.parentSettings.value;

      return Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            // High Risk
            _buildRiskLevelTile(
              title: 'High Risk',
              subtitle: 'Auto block + Popup + Notifikasi urgent',
              icon: Icons.dangerous_outlined,
              color: Colors.red,
              value: settings?.highRiskAutoBlock ?? true,
              onChanged: (value) {
                final newSettings =
                    (settings ?? ParentSettings(userId: 'current_user'))
                        .copyWith(highRiskAutoBlock: value);
                controller.updateParentSettings(newSettings);
              },
            ),
            const Divider(height: 24),

            // Medium Risk
            _buildRiskLevelTile(
              title: 'Medium Risk',
              subtitle: 'Popup warning + Notifikasi ke orang tua',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              value: settings?.mediumRiskNotify ?? true,
              onChanged: (value) {
                final newSettings =
                    (settings ?? ParentSettings(userId: 'current_user'))
                        .copyWith(mediumRiskNotify: value);
                controller.updateParentSettings(newSettings);
              },
            ),
            const Divider(height: 24),

            // Low Risk
            _buildRiskLevelTile(
              title: 'Low Risk',
              subtitle: 'Peringatan ringan tanpa block',
              icon: Icons.info_outline,
              color: Colors.yellow.shade700,
              value: settings?.lowRiskWarning ?? true,
              onChanged: (value) {
                final newSettings =
                    (settings ?? ParentSettings(userId: 'current_user'))
                        .copyWith(lowRiskWarning: value);
                controller.updateParentSettings(newSettings);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRiskLevelTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
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
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.raleway(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ],
    );
  }

  Widget _buildStatisticsCard(DetectionController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: const Color(0xFF4A90E2), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Deteksi Hari Ini',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'High',
                  controller.highRiskCount.value.toString(),
                  Colors.red,
                ),
                _buildStatItem(
                  'Medium',
                  controller.mediumRiskCount.value.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Low',
                  controller.lowRiskCount.value.toString(),
                  Colors.yellow.shade700,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSetPinDialog(
    DetectionController controller,
    BuildContext context,
    bool isUpdate,
  ) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF4A90E2)),
            const SizedBox(width: 12),
            Text(
              isUpdate ? 'Ubah PIN' : 'Set PIN Baru',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PIN digunakan untuk menonaktifkan deteksi sementara (4-6 digit)',
              style: GoogleFonts.raleway(
                color: const Color(0xFF64748B),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'PIN Baru',
                hintText: '••••',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Konfirmasi PIN',
                hintText: '••••',
                prefixIcon: const Icon(Icons.lock_clock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text;
              final confirm = confirmController.text;

              if (!ParentSettings.isValidPin(pin)) {
                Get.snackbar(
                  'Error',
                  'PIN harus 4-6 digit angka',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (pin != confirm) {
                Get.snackbar(
                  'Error',
                  'PIN tidak cocok',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final settings = controller.parentSettings.value;
              final newSettings =
                  (settings ?? ParentSettings(userId: 'current_user')).copyWith(
                    pin: pin,
                  );
              controller.updateParentSettings(newSettings);

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
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
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: activeColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.raleway(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
