import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../../../controllers/link_controller.dart';
import '../../../services/monitoring/auto_screenshot_service.dart';
import '../../widgets/cbt_intervention_popup.dart';
import '../../widgets/child_pin_verification_dialog.dart';
import '../auth/login_screen.dart';
import 'dart:async';
import 'user_personal_information_screen.dart';
import 'user_change_password_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  bool _isVerified = false;
  DateTime? _loginTime;

  // Monitoring dari Orang Tua
  bool _parentalMonitoringEnabled = false;
  Timer? _monitoringTimer;
  AutoScreenshotService? _screenshotService;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Initialize AutoScreenshotService jika belum ada
    if (!Get.isRegistered<AutoScreenshotService>()) {
      Get.put(AutoScreenshotService());
    }
    _screenshotService = Get.find<AutoScreenshotService>();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    // Dummy Data for Profile
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    if (!mounted) return;

    setState(() {
      _name = 'Zikri (Dummy)';
      _email = 'zikri@example.com';
      _isVerified = true;
      _loginTime = DateTime.now();
    });
  }

  Future<void> _logout() async {
    // Stop monitoring jika aktif
    if (_parentalMonitoringEnabled) {
      await _stopParentalMonitoring();
    }

    await SecureStorageService.clearAllData();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Toggle Monitoring dari Orang Tua
  Future<void> _toggleParentalMonitoring(bool value) async {
    // Jika mau menonaktifkan monitoring, minta PIN dulu
    if (!value && _parentalMonitoringEnabled) {
      // Show PIN verification dialog
      final result = await ChildPinVerificationDialog.show(
        context: context,
        onPinSubmit: (pin) async {
          // Verify PIN
          final storedPin = await SecureStorageService.readData('parent_pin');

          if (storedPin == null) {
            // Jika belum ada PIN yang diset, beri peringatan
            Navigator.of(context).pop(false);
            Get.snackbar(
              '⚠️ PIN Belum Diset',
              'Orang tua belum mengatur PIN. Silakan hubungi orang tua.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            return;
          }

          if (pin == storedPin) {
            // PIN benar, tutup dialog dan lanjutkan stop monitoring
            Navigator.of(context).pop(true);

            setState(() {
              _parentalMonitoringEnabled = false;
            });

            await _stopParentalMonitoring();

            Get.snackbar(
              '✅ Verifikasi Berhasil',
              'Monitoring telah dinonaktifkan',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          } else {
            // PIN salah
            Navigator.of(context).pop(false);
            Get.snackbar(
              '❌ PIN Salah',
              'PIN yang Anda masukkan tidak sesuai',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
      );

      // Jika user cancel atau PIN salah, kembalikan toggle ke posisi ON
      if (result != true) {
        setState(() {
          _parentalMonitoringEnabled = true;
        });
      }
    } else if (value && !_parentalMonitoringEnabled) {
      // Mengaktifkan monitoring (tidak perlu PIN)
      setState(() {
        _parentalMonitoringEnabled = true;
      });
      await _startParentalMonitoring();
    }
  }

  // Mulai Monitoring dari Orang Tua
  Future<void> _startParentalMonitoring() async {
    try {
      // Start auto screenshot service
      await _screenshotService?.startAutoScreenshot();

      // Tampilkan notifikasi pertama
      Get.snackbar(
        '✅ Monitoring Aktif',
        'Monitoring dari orang tua telah diaktifkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Trigger sequential popup demo: LOW → MEDIUM → HIGH
      _triggerSequentialPopups();
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Gagal memulai monitoring: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _parentalMonitoringEnabled = false;
      });
    }
  }

  // Hentikan Monitoring dari Orang Tua
  Future<void> _stopParentalMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    await _screenshotService?.stopAutoScreenshot();

    Get.snackbar(
      'ℹ️ Monitoring Dihentikan',
      'Monitoring dari orang tua telah dinonaktifkan',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Trigger Sequential Popups untuk Demo (LOW → MEDIUM → HIGH)
  void _triggerSequentialPopups() {
    if (!mounted || !_parentalMonitoringEnabled) return;

    // 3 detik setelah toggle ON → Popup LOW
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !_parentalMonitoringEnabled) return;
      _showPopup('low', 'Instagram', 'Konten sensitif terdeteksi');

      // 5 detik setelah popup LOW → Tutup LOW, tampilkan MEDIUM
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted || !_parentalMonitoringEnabled) return;
        Get.back(); // Tutup popup LOW

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted || !_parentalMonitoringEnabled) return;
          _showPopup('medium', 'TikTok', 'Konten berisiko terdeteksi');

          // 5 detik setelah popup MEDIUM → Tutup MEDIUM, tampilkan HIGH
          Future.delayed(const Duration(seconds: 5), () {
            if (!mounted || !_parentalMonitoringEnabled) return;
            Get.back(); // Tutup popup MEDIUM

            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted || !_parentalMonitoringEnabled) return;
              _showPopup('high', 'Browser', 'Konten pornografi terdeteksi');
            });
          });
        });
      });
    });
  }

  // Show individual popup
  void _showPopup(String level, String app, String content) {
    if (!mounted || !_parentalMonitoringEnabled) return;

    CBTInterventionPopup.show(
      context: context,
      riskLevel: level,
      appName: app,
      contentType: content,
      onClose: () {
        print('Popup $level closed');
      },
      onCloseApp: () {
        print('Close app requested - Level: $level');
      },
      onOpenChatbot: () {
        print('Open chatbot requested');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90E2), Color(0xFF8E2DE2)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child:
                              // Use logo if available, comparable to Parent Profile
                              Image.asset(
                                'assets/images/logo_paradise.jpg',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xFF3F88EB),
                                    child: Icon(
                                      Icons.shield,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Profile Pengguna',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Settings/Refresh Button
                      GestureDetector(
                        onTap: _loadProfile,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Card
                          _buildProfileCard(),
                          const SizedBox(height: 24),

                          // Stats Card (Gradient) (Replaces old StatsRow)
                          _buildStatsCard(),
                          const SizedBox(height: 24),

                          // Quick Settings (Menu Fitur) - New section replacing inline text
                          _buildQuickSettings(),
                          const SizedBox(height: 24),

                          // Parent Link Section
                          _buildLinkToParentSection(),
                          const SizedBox(height: 20),

                          // Monitoring dari Orang Tua Section
                          _buildParentalMonitoringSection(),
                          const SizedBox(height: 32),

                          // Logout Button
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3F88EB), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                (_name != null && _name!.isNotEmpty)
                    ? _name![0].toUpperCase()
                    : 'U',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3F88EB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name ?? 'Pengguna',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? '-',
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'User Regular',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF1E40AF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              _loginTime != null
                  ? '${_loginTime!.hour}:${_loginTime!.minute.toString().padLeft(2, '0')}'
                  : '--:--',
              'Login Terakhir',
              Icons.access_time_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildStatItem(
              _isVerified ? 'Verified' : 'Unverified',
              'Status Akun',
              Icons.verified_user_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Fitur',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          'Informasi Pribadi',
          'Data diri, kontak & alamat',
          Icons.person_outline_rounded,
          Colors.blue,
          onTap: () {
            Get.to(() => const UserPersonalInformationScreen());
          },
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          'Ganti Password',
          'Perbarui kata sandi akun',
          Icons.lock_outline_rounded,
          Colors.purple,
          onTap: () {
            Get.to(() => const UserChangePasswordScreen());
          },
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
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
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkToParentSection() {
    final linkController = Get.isRegistered<LinkController>()
        ? Get.find<LinkController>()
        : Get.put(LinkController());

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Text(
                  'Hubungkan Orang Tua',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (linkController.isParentModeActive.value)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF166534)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proteksi Aktif',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Perangkat terhubung dengan orang tua',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF166534),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan kode 6 digit dari HP orang tua:',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showInputCodeDialog(context, linkController),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Masukkan Kode',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentalMonitoringSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _parentalMonitoringEnabled
              ? const Color(0xFF10B981)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: _parentalMonitoringEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _parentalMonitoringEnabled
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _parentalMonitoringEnabled
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 20,
                  color: _parentalMonitoringEnabled
                      ? const Color(0xFF10B981)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring dari Orang Tua',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      _parentalMonitoringEnabled ? 'Aktif' : 'Nonaktif',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: _parentalMonitoringEnabled
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: _parentalMonitoringEnabled,
                  onChanged: _toggleParentalMonitoring,
                  activeColor: const Color(0xFF10B981),
                  activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _parentalMonitoringEnabled
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: _parentalMonitoringEnabled
                      ? const Color(0xFF166534)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _parentalMonitoringEnabled
                        ? 'Sistem sedang merekam aktivitas layar dan mendeteksi konten berisiko secara real-time. Popup peringatan akan muncul otomatis.'
                        : 'Aktifkan untuk memulai monitoring aktivitas layar oleh orang tua. Sistem akan mendeteksi dan memblokir konten tidak aman.',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: _parentalMonitoringEnabled
                          ? const Color(0xFF166534)
                          : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded),
            const SizedBox(width: 8),
            Text(
              'Keluar Aplikasi',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputCodeDialog(
    BuildContext context,
    LinkController linkController,
  ) {
    final codeController = TextEditingController();
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.link_rounded, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                Text(
                  'Masukkan Kode',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masukkan 6 digit kode yang tampil di HP orang tua.',
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "000000",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Batal',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final code = codeController.text;
                        if (code.length != 6) return;

                        setState(() => isSubmitting = true);
                        final success = await linkController.joinParent(code);
                        setState(() => isSubmitting = false);

                        if (success) {
                          Get.back();
                          Get.snackbar(
                            'Berhasil',
                            'Berhasil terhubung dengan orang tua!',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Gagal',
                            'Kode tidak valid',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Hubungkan'),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}
