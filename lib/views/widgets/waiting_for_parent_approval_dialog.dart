import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog waiting untuk approval dari orang tua (Device ANAK)
class WaitingForParentApprovalDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final String childName;

  const WaitingForParentApprovalDialog({
    super.key,
    required this.onCancel,
    this.childName = '',
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onCancel,
    String childName = '',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WaitingForParentApprovalDialog(
        onCancel: onCancel,
        childName: childName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.hourglass_empty,
                    color: const Color(0xFF3B82F6),
                    size: 32,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Menunggu Konfirmasi',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Permintaan stop monitoring telah dikirim ke orang tua.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: const Color(0xFF92400E),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tunggu approval untuk melanjutkan',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Timeout info
            Text(
              'Request akan otomatis dibatalkan dalam 5 menit',
              style: GoogleFonts.raleway(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Batal Permintaan',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
