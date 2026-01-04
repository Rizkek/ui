import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isSmallScreen;
  final VoidCallback onDetail;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isSmallScreen,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton.icon(
          onPressed: onDetail,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
          ),
          icon: const Icon(Icons.chevron_right, size: 18),
          label: Text(
            'Lihat semua',
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
