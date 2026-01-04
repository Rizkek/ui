import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCard extends StatelessWidget {
  final String appName;
  final String detections;
  final String percentage;
  final String riskLevel; // kept for compatibility but not shown
  final Color riskColor; // used for accent/icon only
  final Color backgroundColor; // universal background color passed by caller
  final IconData icon;
  final bool isSmallScreen;

  const AppCard({
    super.key,
    required this.appName,
    required this.detections,
    required this.percentage,
    required this.riskLevel,
    required this.riskColor,
    required this.backgroundColor,
    required this.icon,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: riskColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1F2937),
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      percentage,
                      style: GoogleFonts.inter(
                        color: riskColor,
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detections,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Risk label intentionally removed for a cleaner, universal look
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
