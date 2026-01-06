import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// CBT Intervention Popup dengan 3 Komponen Lengkap
/// - Trigger Identification
/// - Psychoeducation
/// - Behavioral Activation
class CBTInterventionPopup extends StatelessWidget {
  final String riskLevel; // 'low', 'medium', 'high'
  final String appName;
  final String? contentType;
  final VoidCallback? onClose;
  final VoidCallback? onCloseApp;
  final VoidCallback? onOpenChatbot;

  const CBTInterventionPopup({
    super.key,
    required this.riskLevel,
    required this.appName,
    this.contentType,
    this.onClose,
    this.onCloseApp,
    this.onOpenChatbot,
  });

  /// Static method untuk menampilkan popup
  static Future<void> show({
    required BuildContext context,
    required String riskLevel,
    required String appName,
    String? contentType,
    VoidCallback? onClose,
    VoidCallback? onCloseApp,
    VoidCallback? onOpenChatbot,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CBTInterventionPopup(
        riskLevel: riskLevel,
        appName: appName,
        contentType: contentType,
        onClose: onClose,
        onCloseApp: onCloseApp,
        onOpenChatbot: onOpenChatbot,
      ),
    );
  }

  Color _getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return const Color(0xFFFFE600); // Yellow
      case 'medium':
        return const Color(0xFFF59E0B); // Orange
      case 'high':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  String _getTitle() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return '⚠️ KONTEN SENSITIF TERDETEKSI';
      case 'medium':
        return '⚠️ KONTEN BERISIKO TERDETEKSI';
      case 'high':
        return '🚨 KONTEN PORNOGRAFI TERDETEKSI';
      default:
        return '⚠️ KONTEN TERDETEKSI';
    }
  }

  Map<String, String> _getCBTContent() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return {
          'trigger':
              'Sepertinya kamu melihat konten yang agak sensitif. Kadang thumbnail atau gambar tertentu bisa memicu rasa penasaran tanpa disadari.',
          'psychoeducation':
              'Konten seperti ini bisa mengganggu fokus dan membentuk kebiasaan scrolling impulsif. Menyadarinya sejak awal membantu kamu tetap terkontrol.',
          'behavioral':
              'Coba lanjutkan ke aktivitas lain yang kamu rencanakan. Kamu bisa alihkan ke aplikasi belajar atau musik santai.',
        };
      case 'medium':
        return {
          'trigger':
              'Kamu sedang terpapar konten yang memicu dorongan visual. Situasi ini sering muncul tanpa disengaja dari rekomendasi aplikasi.',
          'psychoeducation':
              'Konten semi-pornografi dapat memperkuat kebiasaan menonton berulang dan memengaruhi kontrol diri, apalagi jika kamu sedang stres atau bosan.',
          'behavioral':
              'Ambil jeda sebentar. Kamu bisa:\n• Tutup aplikasi ini\n• Buka sesuatu yang lebih aman\n• Tarik napas dalam 30 detik',
        };
      case 'high':
        return {
          'trigger':
              'Sistem mendeteksi konten pornografi eksplisit. Situasi seperti ini sering memicu dorongan kuat dan pola konsumsi impulsif.',
          'psychoeducation':
              'Paparan pornografi berulang dapat memengaruhi regulasi emosi, mengubah pola pikir tentang relasi, dan memicu kebiasaan adiktif. Mengambil langkah cepat di momen ini sangat penting.',
          'behavioral':
              'Konten ini diblokir untuk melindungi kamu. Kamu bisa mengalihkan aktivitas, lakukan deep breathing 30 detik, atau gunakan bantuan CBT chatbot.',
        };
      default:
        return {
          'trigger': 'Konten berisiko terdeteksi.',
          'psychoeducation':
              'Paparan konten ini dapat memengaruhi kebiasaan digital kamu.',
          'behavioral': 'Ambil jeda dan alihkan ke aktivitas lain.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final cbtContent = _getCBTContent();
    final riskColor = _getRiskColor();

    return PopScope(
      canPop: riskLevel.toLowerCase() != 'high', // High risk tidak bisa back
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: riskColor.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getTitle(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: riskLevel.toLowerCase() == 'low'
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: riskLevel.toLowerCase() == 'low'
                            ? Colors.black12
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        appName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: riskLevel.toLowerCase() == 'low'
                              ? const Color(0xFF1F2937)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Trigger Identification
                      _buildCBTSection(
                        icon: '🧩',
                        title: 'Trigger Identification',
                        content: cbtContent['trigger']!,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 16),

                      // 2. Psychoeducation
                      _buildCBTSection(
                        icon: '📘',
                        title: 'Psychoeducation',
                        content: cbtContent['psychoeducation']!,
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 16),

                      // 3. Behavioral Activation
                      _buildCBTSection(
                        icon: '⚡',
                        title: 'Behavioral Activation',
                        content: cbtContent['behavioral']!,
                        color: const Color(0xFF10B981),
                      ),

                      // High Risk Info
                      if (riskLevel.toLowerCase() == 'high') ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sistem otomatis:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCheckItem('Memblokir konten'),
                              _buildCheckItem('Menyimpan log risiko'),
                              _buildCheckItem(
                                'Mengirim notifikasi ke parental (jika ON)',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    if (riskLevel.toLowerCase() == 'medium' ||
                        riskLevel.toLowerCase() == 'high') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            onCloseApp?.call();
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Tutup Aplikasi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (riskLevel.toLowerCase() != 'high') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            onOpenChatbot?.call();
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Bicara dengan AI Chatbot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          onClose?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tutup',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCBTSection({
    required String icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
