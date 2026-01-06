import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/risk_detection.dart';
import '../views/widgets/content_block_popup.dart';

/// Helper untuk testing popup block dengan berbagai level risiko
class TestPopupHelper {
  /// Menampilkan dialog untuk memilih level risiko
  static Future<void> showRiskLevelSelector(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Test Popup Blok Konten',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Pilih level risiko untuk mensimulasikan deteksi:',
          style: GoogleFonts.raleway(),
        ),
        actions: [
          // Tombol Low Risk
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTestBlockPopup(context: context, riskLevel: RiskLevel.low);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Low Risk',
                style: GoogleFonts.outfit(
                  color: Colors.yellow.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Tombol Medium Risk
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTestBlockPopup(
                context: context,
                riskLevel: RiskLevel.medium,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Medium Risk',
                style: GoogleFonts.outfit(
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Tombol High Risk
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTestBlockPopup(context: context, riskLevel: RiskLevel.high);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'High Risk',
                style: GoogleFonts.outfit(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan popup blok dengan data dummy sesuai level risiko
  static Future<void> _showTestBlockPopup({
    required BuildContext context,
    required RiskLevel riskLevel,
  }) {
    // Data dummy berdasarkan level risiko
    final detection = RiskDetection(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      appName: _getAppName(riskLevel),
      packageName: _getPackageName(riskLevel),
      riskLevel: riskLevel,
      detectedContent: _getContentDescription(riskLevel),
      detectedAt: DateTime.now(),
      isBlocked: riskLevel == RiskLevel.high,
      triggers: _getTriggers(riskLevel),
    );

    return ContentBlockPopup.show(
      context: context,
      detection: detection,
      onPsychoeducationTap: () {
        Navigator.pop(context);
        _showPsychoeducationInfo(context, riskLevel);
      },
    );
  }

  /// Menampilkan informasi psikoedukatif
  static Future<void> _showPsychoeducationInfo(
    BuildContext context,
    RiskLevel riskLevel,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Informasi Penting',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getPsychoeducationTitle(riskLevel),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: _getRiskColor(riskLevel),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getPsychoeducationContent(riskLevel),
                style: GoogleFonts.raleway(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Mendapatkan nama aplikasi berdasarkan level
  static String _getAppName(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Chrome Browser';
      case RiskLevel.medium:
        return 'Instagram';
      case RiskLevel.high:
        return 'Situs Pornografi (Blocked)';
    }
  }

  /// Mendapatkan package name berdasarkan level
  static String _getPackageName(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'com.android.chrome';
      case RiskLevel.medium:
        return 'com.instagram.android';
      case RiskLevel.high:
        return 'com.blocked.content';
    }
  }

  /// Mendapatkan deskripsi konten berdasarkan level
  static String _getContentDescription(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Konten dengan sedikit elemen yang tidak sesuai umur';
      case RiskLevel.medium:
        return 'Konten dengan elemen-elemen yang bersifat suggestive/tidak sesuai umur';
      case RiskLevel.high:
        return 'Konten pornografi atau sangat tidak sesuai umur';
    }
  }

  /// Mendapatkan trigger berdasarkan level
  static List<String> _getTriggers(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return ['Partial Nudity'];
      case RiskLevel.medium:
        return ['Adult Content', 'Suggestive Imagery'];
      case RiskLevel.high:
        return ['Explicit Content', 'NSFW', 'Sexual Material'];
    }
  }

  /// Mendapatkan judul edukasi
  static String _getPsychoeducationTitle(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Konten Dengan Batasan Umur';
      case RiskLevel.medium:
        return 'Konten yang Tidak Sesuai untuk Anak-anak';
      case RiskLevel.high:
        return 'Konten Berbahaya - Akses Diblokir';
    }
  }

  /// Mendapatkan konten edukasi
  static String _getPsychoeducationContent(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Konten ini mengandung elemen yang mungkin tidak sesuai untuk usia Anda. '
            'Orang tua Anda telah diberitahu tentang akses ini. '
            'Silakan berkomunikasi dengan orang tua Anda jika Anda memiliki pertanyaan.';
      case RiskLevel.medium:
        return 'Konten yang Anda coba akses memiliki rating untuk dewasa dan tidak direkomendasikan untuk anak-anak. '
            'Pihak pengawas Anda telah menerima notifikasi. '
            'Kami mendorong Anda untuk berbicara dengan orang tua atau wali tentang kekhawatiran apa pun.';
      case RiskLevel.high:
        return 'Konten ini telah diidentifikasi sebagai tidak aman dan telah diblokir. '
            'Akses ke konten eksplisit atau tidak layak demi melindungi kesehatan dan keselamatan Anda. '
            'Jika Anda merasa penyaringan ini terlalu ketat, silakan diskusikan dengan orang tua Anda.';
    }
  }

  /// Mendapatkan warna berdasarkan level
  static Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.yellow.shade700;
      case RiskLevel.medium:
        return Colors.orange.shade600;
      case RiskLevel.high:
        return Colors.red.shade600;
    }
  }
}
