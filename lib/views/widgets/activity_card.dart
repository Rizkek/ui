import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final String time;
  final String appName;
  final String action;
  final String riskLevel;
  final Color riskColor;
  final Color backgroundColor;
  final bool isSmallScreen;

  const ActivityCard({
    super.key,
    required this.time,
    required this.appName,
    required this.action,
    required this.riskLevel,
    required this.riskColor,
    required this.backgroundColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                      riskLevel,
                      style: GoogleFonts.inter(
                        color: riskColor,
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  action,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w500,
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
