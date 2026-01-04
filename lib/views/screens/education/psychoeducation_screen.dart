import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../models/risk_detection.dart';

/// Screen untuk menampilkan konten psychoeducation
class PsychoeducationScreen extends StatelessWidget {
  final RiskDetection detection;

  const PsychoeducationScreen({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edukasi & Pemahaman',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildWhyDangerousSection(),
            const SizedBox(height: 24),
            _buildImpactSection(),
            const SizedBox(height: 24),
            _buildWhatToDoSection(),
            const SizedBox(height: 24),
            _buildParentGuidanceSection(),
            const SizedBox(height: 24),
            _buildResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            detection.getRiskColor(),
            detection.getRiskColor().withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: detection.getRiskColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(detection.getRiskIcon(), size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            detection.getRiskLabel(),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mari pahami bersama mengapa ini penting',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyDangerousSection() {
    final content = _getWhyDangerousContent();

    return _buildSection(
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      title: 'Mengapa Ini Berbahaya?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['description']!,
            style: GoogleFonts.raleway(
              fontSize: 15,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          ...List<String>.from(content['points'] as List).map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: detection.getRiskColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    return _buildSection(
      icon: Icons.psychology_outlined,
      iconColor: Colors.purple,
      title: 'Dampak Psikologis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getImpactPoints().map((impact) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  impact['icon'] as IconData,
                  size: 20,
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        impact['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        impact['description'] as String,
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWhatToDoSection() {
    return _buildSection(
      icon: Icons.lightbulb_outline,
      iconColor: Colors.amber,
      title: 'Apa Yang Harus Dilakukan?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getActionSteps().asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParentGuidanceSection() {
    return _buildSection(
      icon: Icons.family_restroom,
      iconColor: Colors.blue,
      title: 'Panduan untuk Orang Tua',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara Berbicara dengan Anak',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ..._getParentGuidance().map((guidance) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        guidance,
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSection() {
    return _buildSection(
      icon: Icons.support_agent,
      iconColor: Colors.green,
      title: 'Sumber Bantuan',
      child: Column(
        children: [
          _buildResourceCard(
            'Helpline Psikolog Anak',
            '021-500-454 (24/7)',
            Icons.phone,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            'Konseling Online',
            'www.sehatmental.id',
            Icons.public,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            'Komunitas Orang Tua',
            'Forum diskusi & sharing',
            Icons.groups,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Content Data Methods
  Map<String, dynamic> _getWhyDangerousContent() {
    switch (detection.riskLevel) {
      case RiskLevel.high:
        return {
          'description':
              'Konten dengan risiko tinggi dapat memberikan dampak serius pada perkembangan mental dan perilaku anak. Paparan konten dewasa atau kekerasan dapat mengganggu perkembangan psikologis normal.',
          'points': [
            'Dapat merusak persepsi anak tentang hubungan yang sehat',
            'Memicu kecanduan dan perilaku kompulsif',
            'Mengganggu perkembangan nilai moral dan etika',
            'Risiko trauma psikologis jangka panjang',
          ],
        };
      case RiskLevel.medium:
        return {
          'description':
              'Konten dengan risiko sedang mungkin tidak langsung berbahaya, namun paparan berulang dapat membentuk kebiasaan yang tidak sehat dan mempengaruhi perilaku anak.',
          'points': [
            'Dapat mempengaruhi persepsi realitas anak',
            'Mengurangi waktu untuk aktivitas produktif',
            'Berpotensi mengarah ke konten lebih berbahaya',
            'Mempengaruhi pola pikir dan nilai-nilai',
          ],
        };
      case RiskLevel.low:
        return {
          'description':
              'Meskipun risikonya rendah, penting untuk tetap mewaspadai konten yang dikonsumsi anak dan memberikan bimbingan yang tepat.',
          'points': [
            'Konten dapat mengandung iklan tidak pantas',
            'Potensi interaksi dengan stranger',
            'Waktu screen time yang berlebihan',
            'Kurang pengawasan dapat meningkatkan risiko',
          ],
        };
    }
  }

  List<Map<String, dynamic>> _getImpactPoints() {
    return [
      {
        'icon': Icons.sentiment_very_dissatisfied,
        'title': 'Dampak Emosional',
        'description':
            'Dapat menyebabkan kecemasan, depresi, dan gangguan emosional lainnya yang mempengaruhi kesehatan mental anak.',
      },
      {
        'icon': Icons.people_outline,
        'title': 'Dampak Sosial',
        'description':
            'Mengubah cara anak berinteraksi dengan teman sebaya dan dapat menyebabkan isolasi sosial atau perilaku tidak pantas.',
      },
      {
        'icon': Icons.school_outlined,
        'title': 'Dampak Akademis',
        'description':
            'Menurunnya fokus belajar, prestasi akademis, dan motivasi untuk kegiatan edukatif.',
      },
      {
        'icon': Icons.bedtime_outlined,
        'title': 'Dampak Fisik',
        'description':
            'Gangguan tidur, kelelahan mata, dan penurunan aktivitas fisik yang dapat mempengaruhi kesehatan.',
      },
    ];
  }

  List<Map<String, String>> _getActionSteps() {
    return [
      {
        'title': 'Berhenti Segera',
        'description':
            'Tutup atau tinggalkan konten tersebut. Jangan merasa penasaran untuk melihat lebih lanjut.',
      },
      {
        'title': 'Bicarakan dengan Orang Tua',
        'description':
            'Ceritakan apa yang kamu lihat kepada orang tua atau orang dewasa yang kamu percaya. Mereka ada untuk membantu, bukan memarahi.',
      },
      {
        'title': 'Jangan Bagikan',
        'description':
            'Jangan membagikan konten tersebut kepada teman-temanmu. Ini untuk melindungi mereka juga.',
      },
      {
        'title': 'Cari Aktivitas Positif',
        'description':
            'Alihkan perhatian ke kegiatan yang lebih bermanfaat seperti membaca, olahraga, atau hobi lainnya.',
      },
    ];
  }

  List<String> _getParentGuidance() {
    return [
      'Tetap tenang dan jangan memarahi anak. Ciptakan ruang aman untuk diskusi terbuka.',
      'Dengarkan perspektif anak tanpa menghakimi. Pahami apa yang mereka lihat dan rasakan.',
      'Jelaskan dengan bahasa yang sesuai usia mengapa konten tersebut tidak pantas.',
      'Berikan contoh konkret tentang dampak negatif dan alternatif yang lebih baik.',
      'Tetapkan aturan digital yang jelas dan konsisten, dengan penjelasan alasannya.',
      'Monitor aktivitas digital secara teratur, namun dengan tetap menghormati privasi anak.',
      'Bangun kepercayaan agar anak merasa nyaman melaporkan konten yang tidak pantas.',
    ];
  }
}
