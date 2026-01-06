import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Screen untuk setup PIN Parental Control
class PINSettingsScreen extends StatefulWidget {
  const PINSettingsScreen({super.key});

  @override
  State<PINSettingsScreen> createState() => _PINSettingsScreenState();
}

class _PINSettingsScreenState extends State<PINSettingsScreen> {
  bool _parentModeEnabled = false;
  bool _isLoading = true;
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // TODO: Load from Firestore/Storage
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _parentModeEnabled = false; // Load actual value
      _isLoading = false;
    });
  }

  Future<void> _toggleParentMode(bool value) async {
    if (value) {
      // Enable parent mode - need to set PIN
      _showSetPINDialog();
    } else {
      // Disable parent mode - need to verify current PIN
      _showVerifyPINDialog();
    }
  }

  void _showSetPINDialog() {
    _pinController.clear();
    _confirmPinController.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            Text(
              'Set PIN Parental',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat PIN 4-6 digit untuk mengunci monitoring. PIN ini akan digunakan untuk menonaktifkan monitoring.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN Baru',
                    hintText: 'Masukkan 4-6 digit',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN tidak boleh kosong';
                    }
                    if (value.length < 4) {
                      return 'PIN minimal 4 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi PIN',
                    hintText: 'Ketik ulang PIN',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != _pinController.text) {
                      return 'PIN tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Simpan PIN dengan aman. Jangan bagikan kepada anak.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Save PIN to Firestore/Storage (encrypted)
                Get.back();
                setState(() {
                  _parentModeEnabled = true;
                });
                Get.snackbar(
                  'Berhasil',
                  'Parental Mode diaktifkan. Monitoring sekarang terkunci.',
                  backgroundColor: const Color(0xFF10B981),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Aktifkan', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showVerifyPINDialog() {
    final pinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Text(
              'Verifikasi PIN',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan PIN untuk menonaktifkan Parental Mode.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Masukkan PIN',
                hintText: '••••••',
                prefixIcon: const Icon(Icons.lock_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Verify PIN from Firestore/Storage
              final enteredPin = pinController.text;
              if (enteredPin == '123456') {
                // Correct PIN (demo)
                Get.back();
                setState(() {
                  _parentModeEnabled = false;
                });
                Get.snackbar(
                  'Berhasil',
                  'Parental Mode dinonaktifkan.',
                  backgroundColor: const Color(0xFF10B981),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar(
                  'PIN Salah',
                  'PIN yang kamu masukkan salah. Coba lagi.',
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Verifikasi', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('PIN Settings', style: GoogleFonts.outfit()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Text(
          'Pengaturan PIN',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
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
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                ),
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
                      Icons.shield_rounded,
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
                          'Parental Control',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lindungi pengaturan dengan PIN',
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

            // Parental Mode Toggle
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktifkan Parental Mode',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kunci monitoring dengan PIN',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _parentModeEnabled,
                        onChanged: _toggleParentMode,
                        activeColor: const Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                  if (_parentModeEnabled) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Status: Aktif',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitoring saat ini terkunci. Anak membutuhkan PIN untuk menonaktifkan monitoring.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Info Section
            Text(
              'Informasi',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.lock_rounded,
              title: 'Keamanan PIN',
              description:
                  'PIN disimpan dengan enkripsi. Pastikan PIN tidak mudah ditebak.',
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.family_restroom_rounded,
              title: 'Kontrol Orang Tua',
              description:
                  'Dengan parental mode, anak tidak bisa menonaktifkan monitoring tanpa PIN.',
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.notifications_active_rounded,
              title: 'Notifikasi Real-time',
              description:
                  'Orang tua akan menerima notifikasi saat konten High Risk terdeteksi.',
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
                    fontSize: 14,
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
        ],
      ),
    );
  }
}
