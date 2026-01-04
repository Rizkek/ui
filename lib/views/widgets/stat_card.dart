import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String count;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double height;
  final bool isSmallScreen;

  const StatCard({
    super.key,
    required this.count,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.height,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmall = screenWidth < 360; // Very small phones
    
    // Adaptive sizing based on screen width
    final iconSize = isExtraSmall ? 34.0 : (isSmallScreen ? 38.0 : 44.0);
    final countFontSize = isExtraSmall ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    final titleFontSize = isExtraSmall ? 11.0 : (isSmallScreen ? 12.0 : 13.0);
    final subtitleFontSize = isExtraSmall ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    final horizontalPadding = isExtraSmall ? 10.0 : 14.0;
    final verticalPadding = isExtraSmall ? 10.0 : 14.0;
    final spacing = isExtraSmall ? 8.0 : 12.0;
    
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
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
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize * 0.5, // Icon size is 50% of container
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111827),
                      fontSize: countFontSize,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
