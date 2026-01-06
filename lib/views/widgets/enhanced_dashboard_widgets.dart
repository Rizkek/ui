import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for Enhanced App Card with percentage
class EnhancedAppCard extends StatelessWidget {
  final String appName;
  final int detectionCount;
  final int totalDetections;
  final Color color;
  final VoidCallback? onTap;

  const EnhancedAppCard({
    super.key,
    required this.appName,
    required this.detectionCount,
    required this.totalDetections,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalDetections > 0
        ? ((detectionCount / totalDetections) * 100).toStringAsFixed(1)
        : '0.0';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // App Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getAppIcon(appName), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // App Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$detectionCount deteksi',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$percentage%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Percentage Bar
            SizedBox(
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: detectionCount / totalDetections,
                      strokeWidth: 3,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    detectionCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAppIcon(String appName) {
    switch (appName.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_filled;
      case 'instagram':
        return Icons.camera_alt;
      case 'whatsapp':
        return Icons.chat;
      case 'chrome':
      case 'browser':
        return Icons.language;
      case 'twitter':
      case 'x':
        return Icons.chat_bubble;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.apps;
    }
  }
}

/// Widget for Trend Indicator with Up/Down arrow
class TrendIndicator extends StatelessWidget {
  final String label;
  final int currentValue;
  final int previousValue;
  final bool isInverted; // true if decrease is good (e.g., detections)

  const TrendIndicator({
    super.key,
    required this.label,
    required this.currentValue,
    required this.previousValue,
    this.isInverted = true,
  });

  @override
  Widget build(BuildContext context) {
    final difference = currentValue - previousValue;
    final isIncrease = difference > 0;
    final isGood = isInverted ? !isIncrease : isIncrease;
    final percentageChange = previousValue > 0
        ? ((difference.abs() / previousValue) * 100).toStringAsFixed(0)
        : '0';

    final color = isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$percentageChange%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (difference != 0) ...[
            const SizedBox(width: 4),
            Text(
              isGood ? 'Lebih baik!' : 'Perlu perhatian',
              style: GoogleFonts.inter(fontSize: 10, color: color),
            ),
          ],
        ],
      ),
    );
  }
}
