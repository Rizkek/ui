import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/risk_detection.dart';
import '../../../controllers/detection_controller.dart';

class ParentHistoryScreen extends StatefulWidget {
  const ParentHistoryScreen({super.key});

  @override
  State<ParentHistoryScreen> createState() => _ParentHistoryScreenState();
}

class _ParentHistoryScreenState extends State<ParentHistoryScreen> {
  // Filters
  RiskLevel? _selectedRisk;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dummy Data List
  final List<RiskDetection> _dummyHistory = [
    RiskDetection(
      id: '1',
      appName: 'TikTok',
      packageName: 'com.zhiliaoapp.musically',
      riskLevel: RiskLevel.high,
      detectedContent: 'Konten Dewasa',
      detectedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isBlocked: true,
      actionTaken: 'blocked',
      triggers: ['adult', 'explicit'],
    ),
    RiskDetection(
      id: '2',
      appName: 'YouTube',
      packageName: 'com.google.android.youtube',
      riskLevel: RiskLevel.medium,
      detectedContent: 'Kata Kasar',
      detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isBlocked: false,
      actionTaken: 'warning_shown',
      triggers: ['bad_word'],
    ),
    RiskDetection(
      id: '3',
      appName: 'Chrome',
      packageName: 'com.android.chrome',
      riskLevel: RiskLevel.high,
      detectedContent: 'Situs Judi',
      detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
      isBlocked: true,
      actionTaken: 'blocked',
      triggers: ['gambling'],
    ),
    RiskDetection(
      id: '4',
      appName: 'Instagram',
      packageName: 'com.instagram.android',
      riskLevel: RiskLevel.low,
      detectedContent: 'Notifikasi Spam',
      detectedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isBlocked: false,
      actionTaken: 'ignored',
      triggers: ['spam'],
    ),
    RiskDetection(
      id: '5',
      appName: 'Mobile Legends',
      packageName: 'com.mobile.legends',
      riskLevel: RiskLevel.medium,
      detectedContent: 'Toxic Chat',
      detectedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isBlocked: false,
      actionTaken: 'continued',
      triggers: ['toxic'],
    ),
    RiskDetection(
      id: '6',
      appName: 'Twitter',
      packageName: 'com.twitter.android',
      riskLevel: RiskLevel.low,
      detectedContent: 'Konten Sensitif',
      detectedAt: DateTime.now().subtract(const Duration(days: 2)),
      isBlocked: false,
      actionTaken: 'ignored',
      triggers: ['sensitive'],
    ),
    RiskDetection(
      id: '7',
      appName: 'WhatsApp',
      packageName: 'com.whatsapp',
      riskLevel: RiskLevel.medium,
      detectedContent: 'Link Phishing',
      detectedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      isBlocked: false,
      actionTaken: 'warning_shown',
      triggers: ['phishing'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Riwayat Deteksi',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Weekly Stats
          _buildWeeklyStats(),

          // Search & Filter
          _buildSearchAndFilter(),

          // List
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    // Dummy Stats consistent with request (Weekly context)
    // Total: 80, High: 15, Medium: 25, Low: 40
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Minggu Ini',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Total', '80', const Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              _buildStatCard('High', '15', Colors.red),
              const SizedBox(width: 12),
              _buildStatCard('Medium', '25', Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard(
                'Low',
                '40',
                const Color(0xFFEAB308), // Yellow-600
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari aplikasi...',
              hintStyle: GoogleFonts.raleway(color: const Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                const SizedBox(width: 8),
                _buildFilterChip('High', RiskLevel.high),
                const SizedBox(width: 8),
                _buildFilterChip('Medium', RiskLevel.medium),
                const SizedBox(width: 8),
                _buildFilterChip('Low', RiskLevel.low),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, RiskLevel? level) {
    final isSelected = _selectedRisk == level;
    Color chipColor;
    if (level == null) {
      chipColor = const Color(0xFF4A90E2);
    } else {
      switch (level) {
        case RiskLevel.high:
          chipColor = Colors.red;
          break;
        case RiskLevel.medium:
          chipColor = Colors.orange;
          break;
        case RiskLevel.low:
          chipColor = const Color(0xFFEAB308); // Yellow
          break;
      }
    }

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.outfit(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRisk = selected ? level : null;
        });
      },
      selectedColor: chipColor,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildHistoryList() {
    final filteredHistory = _dummyHistory.where((item) {
      final matchesRisk =
          _selectedRisk == null || item.riskLevel == _selectedRisk;
      final matchesSearch = item.appName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesRisk && matchesSearch;
    }).toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data ditemukan',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        return _buildDetectionItem(filteredHistory[index]);
      },
    );
  }

  Widget _buildDetectionItem(RiskDetection detection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDetailDialog(detection),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: detection.getRiskColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    detection.getRiskIcon(),
                    color: detection.getRiskColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection.appName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detection.getRiskLabel(),
                        style: GoogleFonts.raleway(
                          color: detection.getRiskColor(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(detection.detectedAt),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Action Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: detection.isBlocked
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: detection.isBlocked
                              ? const Color(0xFFFECACA)
                              : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Text(
                        detection.isBlocked ? 'Diblokir' : 'Lolos',
                        style: GoogleFonts.raleway(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: detection.isBlocked
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(RiskDetection detection) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: detection.getRiskColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    detection.getRiskIcon(),
                    color: detection.getRiskColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Aktivitas',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        detection.appName,
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content
            _buildDetailRow(
              'Waktu Deteksi',
              DateFormat('dd MMM yyyy, HH:mm').format(detection.detectedAt),
            ),
            _buildDetailRow('Konten Terdeteksi', detection.detectedContent),

            const Divider(height: 32),

            // Risk & Action Section
            Text(
              'Analisis Keamanan',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            _buildStatusContainer(
              'Tingkat Risiko: ${detection.getRiskLabel()}',
              _getRiskDescription(detection.riskLevel),
              detection.getRiskColor(),
              Icons.shield_outlined,
            ),
            const SizedBox(height: 12),
            _buildStatusContainer(
              'Aksi Sistem: ${detection.isBlocked ? "Diblokir Otomatis" : "Hanya Peringatan"}',
              detection.isBlocked
                  ? 'Aplikasi ditutup paksa untuk melindungi anak.'
                  : 'Anak diberikan peringatan namun memilih untuk melanjutkan.',
              detection.isBlocked ? Colors.red : Colors.orange,
              detection.isBlocked ? Icons.block : Icons.warning_amber_rounded,
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF64748B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskDescription(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'Konten mengandung unsur dewasa, kekerasan verbal ekstrim, atau judi online. Sangat berbahaya.';
      case RiskLevel.medium:
        return 'Konten mengandung kata kasar, bullying ringan, atau topik yang tidak pantas untuk usia anak.';
      case RiskLevel.low:
        return 'Potensi spam, iklan mengganggu, atau konten yang perlu pengawasan orang tua.';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.raleway(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContainer(
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    color: Colors.black87,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
