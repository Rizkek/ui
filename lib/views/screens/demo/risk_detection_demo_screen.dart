import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Demo screen untuk Risk Detection System - User Version
class RiskDetectionDemoScreen extends StatefulWidget {
  const RiskDetectionDemoScreen({super.key});

  @override
  State<RiskDetectionDemoScreen> createState() =>
      _RiskDetectionDemoScreenState();
}

class _RiskDetectionDemoScreenState extends State<RiskDetectionDemoScreen> {
  // Dummy Statistics
  int highRiskCount = 3;
  int mediumRiskCount = 7;
  int lowRiskCount = 12;
  int totalDetections = 22;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Deteksi Konten Berisiko',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Card
            _buildStatisticsCard(),

            const SizedBox(height: 24),

            _buildSectionTitle('Level Risiko Konten'),
            const SizedBox(height: 12),

            // Risk Levels Explanation
            _buildRiskLevelCard(
              title: 'High Risk - Risiko Tinggi',
              subtitle: 'Konten dewasa, kekerasan, self-harm',
              icon: Icons.dangerous_outlined,
              color: Colors.red,
              count: highRiskCount,
              description: 'Konten diblokir otomatis untuk melindungi Anda',
            ),

            const SizedBox(height: 12),

            _buildRiskLevelCard(
              title: 'Medium Risk - Risiko Sedang',
              subtitle: 'Gambling, dating apps, konten sugestif',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              count: mediumRiskCount,
              description: 'Peringatan ditampilkan dan orang tua diberitahu',
            ),

            const SizedBox(height: 12),

            _buildRiskLevelCard(
              title: 'Low Risk - Risiko Rendah',
              subtitle: 'Stranger chat, anonymous apps',
              icon: Icons.info_outline,
              color: Colors.yellow.shade700,
              count: lowRiskCount,
              description: 'Peringatan ringan untuk kehati-hatian',
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Simulasi Deteksi'),
            const SizedBox(height: 12),

            // Trigger Buttons untuk Test
            Row(
              children: [
                Expanded(
                  child: _buildTriggerButton(
                    'High Risk',
                    Icons.dangerous_outlined,
                    Colors.red,
                    () => _showHighRiskPopup(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTriggerButton(
                    'Medium Risk',
                    Icons.warning_amber_rounded,
                    Colors.orange,
                    () => _showMediumRiskPopup(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTriggerButton(
                    'Low Risk',
                    Icons.info_outline,
                    Colors.yellow.shade700,
                    () => _showLowRiskWarning(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap tombol di atas untuk melihat contoh popup deteksi',
                      style: GoogleFonts.raleway(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
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

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proteksi Aktif',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Kamu terlindungi dari konten berbahaya',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'High',
                  highRiskCount.toString(),
                  Colors.red.shade300,
                ),
                _buildStatItem(
                  'Medium',
                  mediumRiskCount.toString(),
                  Colors.orange.shade300,
                ),
                _buildStatItem(
                  'Low',
                  lowRiskCount.toString(),
                  Colors.yellow.shade300,
                ),
                _buildStatItem(
                  'Total',
                  totalDetections.toString(),
                  Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildRiskLevelCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simplified Popups - Cuma Tampilan Saja

  void _showHighRiskPopup() {
    setState(() {
      highRiskCount++;
      totalDetections++;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSimplePopup(
        color: Colors.red,
        icon: Icons.dangerous_outlined,
        title: 'Konten Terdeteksi!',
        riskLevel: 'Risiko Tinggi',
        description: 'Konten dewasa atau berbahaya terdeteksi',
        action: 'Konten diblokir otomatis',
        triggers: ['adult', 'explicit', 'porn'],
      ),
    );
  }

  void _showMediumRiskPopup() {
    setState(() {
      mediumRiskCount++;
      totalDetections++;
    });

    showDialog(
      context: context,
      builder: (context) => _buildSimplePopup(
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
        title: 'Peringatan Konten',
        riskLevel: 'Risiko Sedang',
        description: 'Konten yang tidak sesuai usia terdeteksi',
        action: 'Orang tua akan diberitahu',
        triggers: ['gambling', 'dating'],
      ),
    );
  }

  void _showLowRiskWarning() {
    setState(() {
      lowRiskCount++;
      totalDetections++;
    });

    Get.snackbar(
      'Peringatan',
      'Konten yang perlu kehati-hatian terdeteksi',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.yellow.shade700,
      colorText: Colors.black87,
      icon: Icon(Icons.info_outline, color: Colors.black87),
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildSimplePopup({
    required Color color,
    required IconData icon,
    required String title,
    required String riskLevel,
    required String description,
    required String action,
    required List<String> triggers,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          riskLevel,
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_outlined, color: color, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                description,
                                style: GoogleFonts.raleway(
                                  fontSize: 14,
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: color,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                action,
                                style: GoogleFonts.raleway(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Triggers
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pemicu Terdeteksi:',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: triggers.map((trigger) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          trigger,
                          style: GoogleFonts.raleway(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.snackbar(
                          'Info',
                          'Di mode asli, ini akan membuka halaman edukasi',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon: const Icon(Icons.psychology_outlined),
                      label: const Text('Pelajari Lebih Lanjut'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tutup'),
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
}
