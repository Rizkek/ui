import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../../../controllers/link_controller.dart';
import '../../../services/monitoring/auto_screenshot_service.dart';
import '../../widgets/cbt_intervention_popup.dart';
import '../auth/login_screen.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  bool _isVerified = false;
  String? _gender;
  int? _age;
  String? _uid;
  DateTime? _loginTime;
  bool _tokenExpired = false;
  bool _updatingName = false;

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
      _gender = 'Laki-laki';
      _age = 25;
      _uid = 'dummy-uid-123456789';
      _loginTime = DateTime.now();
      _tokenExpired = false;
    });
  }

  Future<void> _promptUpdateDisplayName() async {
    final controller = TextEditingController(text: _name ?? '');

    // Using simple dialog or bottom sheet for input
    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ubah Display Name',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nama ini akan tampil di profil Anda.',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    hintText: 'Masukkan nama baru',
                    hintStyle: GoogleFonts.raleway(
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF3B82F6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (newName == null) return; // dismissed
    if (newName.isEmpty || newName == _name) {
      if (newName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() => _updatingName = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada pengguna aktif')),
        );
        return;
      }

      await user.updateDisplayName(newName);
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;

      if (refreshed?.displayName?.trim() == newName) {
        await SecureStorageService.updateDisplayName(newName);
        if (!mounted) return;
        setState(() {
          _name = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memverifikasi perubahan nama di Firebase'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui nama: $e')));
    } finally {
      if (mounted) setState(() => _updatingName = false);
    }
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
    setState(() {
      _parentalMonitoringEnabled = value;
    });

    if (value) {
      await _startParentalMonitoring();
    } else {
      await _stopParentalMonitoring();
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
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
                      // Refresh Button
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

                          // Stats Row
                          _buildStatsRow(),
                          const SizedBox(height: 24),

                          // Personal Info
                          _sectionCard(
                            title: 'Informasi Pribadi',
                            icon: Icons.person_outline,
                            children: [
                              _editableInfoRow(
                                'Nama Lengkap',
                                _name ?? '-',
                                onEdit: _updatingName
                                    ? null
                                    : _promptUpdateDisplayName,
                              ),
                              const SizedBox(height: 16),
                              _infoRow('Email', _email ?? '-'),
                              const SizedBox(height: 16),
                              _infoRow('Jenis Kelamin', _gender ?? '-'),
                              const SizedBox(height: 16),
                              _infoRow(
                                'Umur',
                                _age != null ? '$_age Tahun' : '-',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Account Security
                          _sectionCard(
                            title: 'Keamanan Akun',
                            icon: Icons.security,
                            children: [
                              _infoRow(
                                'Status Verifikasi',
                                _isVerified
                                    ? 'Terverifikasi'
                                    : 'Belum Verifikasi',
                                valueColor: _isVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                'Token Session',
                                _tokenExpired ? 'Expired' : 'Valid',
                                valueColor: _tokenExpired
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
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
                  color: const Color(0xFF3B82F6),
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.schedule,
            label: 'Login Terakhir',
            value: _loginTime != null
                ? '${_loginTime!.hour}:${_loginTime!.minute}'
                : '-',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.fingerprint,
            label: 'ID Pengguna',
            value: _uid != null && _uid!.length > 4
                ? '...${_uid!.substring(_uid!.length - 4)}'
                : '-',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.raleway(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(icon, size: 20, color: const Color(0xFF64748B)),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor ?? const Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _editableInfoRow(String label, String value, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ],
        ),
      ],
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
            if (linkController.isLinkedToParent.value)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF166534),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Terhubung dengan ${linkController.parentName.value}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF166534),
                          fontWeight: FontWeight.bold,
                        ),
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
                    'Masukkan kode 6-digit dari orang tua:',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cth: 123-456',
                      hintStyle: GoogleFonts.raleway(
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) async {
                      if (value.replaceAll('-', '').length == 6) {
                        final code = value.replaceAll('-', '');
                        await linkController.verifyCode(code);
                      }
                    },
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
        child: Text(
          'Keluar Aplikasi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
