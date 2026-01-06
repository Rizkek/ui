import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/risk_detection.dart';
import '../views/widgets/content_block_popup.dart';

/// Quick launcher untuk test popup - bisa dipanggil dari mana saja
class QuickTestPopupLauncher {
  /// Menampilkan bottom sheet dengan opsi testing (alternative UI)
  static Future<void> showTestOptionsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🧪 Test Popup Blok Konten',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih level risiko untuk testing',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            _buildTestOption(
              context,
              level: RiskLevel.low,
              title: 'Low Risk Testing',
              subtitle: 'Konten dengan elemen minimal',
              color: Colors.yellow.shade700,
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 12),
            _buildTestOption(
              context,
              level: RiskLevel.medium,
              title: 'Medium Risk Testing',
              subtitle: 'Konten dengan elemen suggestive',
              color: Colors.orange.shade600,
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 12),
            _buildTestOption(
              context,
              level: RiskLevel.high,
              title: 'High Risk Testing',
              subtitle: 'Konten pornografi (BLOCKED)',
              color: Colors.red.shade600,
              icon: Icons.dangerous_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF64748B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build test option tile
  static Widget _buildTestOption(
    BuildContext context, {
    required RiskLevel level,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _triggerTestPopup(context, level);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  /// Trigger popup dengan data dummy
  static Future<void> _triggerTestPopup(
    BuildContext context,
    RiskLevel riskLevel,
  ) {
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

    return ContentBlockPopup.show(context: context, detection: detection);
  }

  // Helper methods
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
}
