import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../models/risk_detection.dart';
import '../../../models/parent_settings.dart';

/// Popup Block Dialog yang muncul otomatis saat konten berisiko terdeteksi
class ContentBlockPopup extends StatelessWidget {
  final RiskDetection detection;
  final ParentSettings? parentSettings;
  final VoidCallback? onPsychoeducationTap;
  final Function(String pin)? onPinEntered;

  const ContentBlockPopup({
    super.key,
    required this.detection,
    this.parentSettings,
    this.onPsychoeducationTap,
    this.onPinEntered,
  });

  /// Static method untuk menampilkan popup
  static Future<void> show({
    required BuildContext context,
    required RiskDetection detection,
    ParentSettings? parentSettings,
    VoidCallback? onPsychoeducationTap,
    Function(String pin)? onPinEntered,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa dismiss dengan tap outside
      builder: (context) => ContentBlockPopup(
        detection: detection,
        parentSettings: parentSettings,
        onPsychoeducationTap: onPsychoeducationTap,
        onPinEntered: onPinEntered,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Tidak bisa back button
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: detection.getRiskColor().withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan animasi
              _buildHeader(),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildRiskInfo(),
                    const SizedBox(height: 20),
                    _buildDetectionDetails(),
                    const SizedBox(height: 20),
                    _buildContentTriggers(),
                    const SizedBox(height: 24),
                    _buildActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            detection.getRiskColor(),
            detection.getRiskColor().withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(detection.getRiskIcon(), color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konten Terdeteksi!',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detection.getRiskLabel(),
                  style: GoogleFonts.raleway(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: detection.getRiskColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: detection.getRiskColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: detection.getRiskColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detection.getActionDescription(),
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Deteksi',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.apps, 'Aplikasi', detection.appName),
        const SizedBox(height: 8),
        _buildDetailRow(
          Icons.access_time,
          'Waktu',
          _formatTime(detection.detectedAt),
        ),
        if (detection.detectedContent.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.description_outlined,
            'Konten',
            detection.detectedContent,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.raleway(
            fontSize: 14,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTriggers() {
    if (detection.triggers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pemicu Terdeteksi',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detection.triggers.map((trigger) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: detection.getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: detection.getRiskColor().withOpacity(0.3),
                ),
              ),
              child: Text(
                trigger,
                style: GoogleFonts.raleway(
                  fontSize: 12,
                  color: detection.getRiskColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // Psychoeducation Button
        if (onPsychoeducationTap != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onPsychoeducationTap?.call();
              },
              icon: const Icon(Icons.psychology_outlined),
              label: const Text('Pelajari Mengapa Ini Berbahaya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Kembali Button (Close)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Aplikasi Aman'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // PIN Override (jika parent mode aktif)
        if (parentSettings?.isParentModeEnabled == true &&
            parentSettings?.pin != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showPinDialog(context),
            icon: const Icon(Icons.lock_open, size: 18),
            label: const Text('Nonaktifkan dengan PIN Orang Tua'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }

  void _showPinDialog(BuildContext context) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF4A90E2)),
            const SizedBox(width: 12),
            Text(
              'Masukkan PIN',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan PIN orang tua untuk menonaktifkan deteksi',
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
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 2,
                  ),
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
              if (parentSettings?.verifyPin(pinController.text) == true) {
                Navigator.of(context).pop(); // Close PIN dialog
                Navigator.of(context).pop(); // Close block popup
                onPinEntered?.call(pinController.text);

                Get.snackbar(
                  'Berhasil',
                  'Deteksi dinonaktifkan sementara',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  'PIN Salah',
                  'PIN yang Anda masukkan tidak valid',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
