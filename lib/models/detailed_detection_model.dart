import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model untuk Risk Detection dengan detail lengkap
class DetailedDetectionModel {
  final String id;
  final String appName;
  final String riskLevel;
  final DateTime timestamp;
  final String? screenshotUrl;
  final Duration? exposureDuration;
  final String userAction; // 'blocked', 'ignored', 'continued', 'closed'
  final Map<String, String>? cbtIntervention;
  final String? contentType;

  DetailedDetectionModel({
    required this.id,
    required this.appName,
    required this.riskLevel,
    required this.timestamp,
    this.screenshotUrl,
    this.exposureDuration,
    required this.userAction,
    this.cbtIntervention,
    this.contentType,
  });

  Color getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return const Color(0xFFFFE600);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String getRiskLabel() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'Risiko Rendah';
      case 'medium':
        return 'Risiko Sedang';
      case 'high':
        return 'Risiko Tinggi';
      default:
        return 'Unknown';
    }
  }

  String getActionLabel() {
    switch (userAction.toLowerCase()) {
      case 'blocked':
        return 'Diblokir oleh sistem';
      case 'ignored':
        return 'Diabaikan';
      case 'continued':
        return 'User lanjut';
      case 'closed':
        return 'Ditutup user';
      default:
        return userAction;
    }
  }
}

/// Dialog untuk menampilkan detail detection
class DetectionDetailDialog extends StatelessWidget {
  final DetailedDetectionModel detection;

  const DetectionDetailDialog({super.key, required this.detection});

  static Future<void> show(
    BuildContext context,
    DetailedDetectionModel detection,
  ) {
    return showDialog(
      context: context,
      builder: (context) => DetectionDetailDialog(detection: detection),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: detection.getRiskColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detail Deteksi',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: detection.riskLevel.toLowerCase() == 'low'
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: detection.riskLevel.toLowerCase() == 'low'
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: detection.riskLevel.toLowerCase() == 'low'
                            ? Colors.black12
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        detection.getRiskLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: detection.riskLevel.toLowerCase() == 'low'
                              ? const Color(0xFF1F2937)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screenshot (with blur for high risk)
                    if (detection.screenshotUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: detection.riskLevel.toLowerCase() == 'high'
                                  ? Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withOpacity(0.3),
                                            Colors.red.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.visibility_off,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            if (detection.riskLevel.toLowerCase() == 'high')
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Konten Diblur untuk Privasi',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Info Items
                    _buildInfoItem(
                      icon: Icons.apps_rounded,
                      label: 'Aplikasi',
                      value: detection.appName,
                    ),
                    _buildInfoItem(
                      icon: Icons.schedule_rounded,
                      label: 'Waktu',
                      value: _formatDateTime(detection.timestamp),
                    ),
                    if (detection.exposureDuration != null)
                      _buildInfoItem(
                        icon: Icons.timer_rounded,
                        label: 'Durasi Paparan',
                        value: _formatDuration(detection.exposureDuration!),
                      ),
                    _buildInfoItem(
                      icon: Icons.flag_rounded,
                      label: 'Aksi Pengguna',
                      value: detection.getActionLabel(),
                    ),
                    if (detection.contentType != null)
                      _buildInfoItem(
                        icon: Icons.category_rounded,
                        label: 'Jenis Konten',
                        value: detection.contentType!,
                      ),

                    // CBT Intervention
                    if (detection.cbtIntervention != null) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Intervensi CBT yang Diberikan',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCBTSection(
                        icon: '🧩',
                        title: 'Trigger Identification',
                        content: detection.cbtIntervention!['trigger'] ?? '-',
                      ),
                      const SizedBox(height: 8),
                      _buildCBTSection(
                        icon: '📘',
                        title: 'Psychoeducation',
                        content:
                            detection.cbtIntervention!['psychoeducation'] ??
                            '-',
                      ),
                      const SizedBox(height: 8),
                      _buildCBTSection(
                        icon: '⚡',
                        title: 'Behavioral Activation',
                        content:
                            detection.cbtIntervention!['behavioral'] ?? '-',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCBTSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} detik';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} menit';
    } else {
      return '${duration.inHours} jam ${duration.inMinutes % 60} menit';
    }
  }
}
