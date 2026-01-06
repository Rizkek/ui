import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../controllers/link_controller.dart';
import '../../../services/test_popup_helper.dart';

class ChildDetailScreen extends StatefulWidget {
  final LinkedChild child;

  const ChildDetailScreen({super.key, required this.child});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Hari Ini';

  // Hidden test feature - untuk mendeteksi tap ganda pada title
  int _titleTapCount = 0;
  DateTime? _lastTitleTapTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Handle tap ganda pada title untuk menampilkan test popup
  void _handleTitleTap() {
    final now = DateTime.now();

    // Reset jika sudah lebih dari 500ms sejak tap terakhir
    if (_lastTitleTapTime != null &&
        now.difference(_lastTitleTapTime!).inMilliseconds > 500) {
      _titleTapCount = 0;
    }

    _titleTapCount++;
    _lastTitleTapTime = now;

    // Jika tap 2x dalam 500ms, tampilkan test menu
    if (_titleTapCount == 2) {
      _titleTapCount = 0; // Reset
      TestPopupHelper.showRiskLevelSelector(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: Text(
            'Detail ${widget.child.name}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.raleway(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistik'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            Tab(icon: Icon(Icons.settings), text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Filter
          Row(
            children: [
              _buildPeriodChip('Hari Ini'),
              const SizedBox(width: 8),
              _buildPeriodChip('Minggu Ini'),
              const SizedBox(width: 8),
              _buildPeriodChip('Bulan Ini'),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Screen Time',
                  '3j 24m',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Alerts',
                  '${widget.child.alertsToday}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Apps Used',
                  '12',
                  Icons.apps,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Blocked', '5', Icons.block, Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart Placeholder - Screen Time
          Text(
            'Screen Time Trend',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartPlaceholder('Line Chart: Jam per hari', Colors.blue),

          const SizedBox(height: 24),

          // Chart Placeholder - App Usage
          Text(
            'Penggunaan Aplikasi',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartPlaceholder('Pie Chart: Breakdown per app', Colors.green),

          const SizedBox(height: 24),

          // Chart Placeholder - NSFW Detection
          Text(
            'NSFW Detection',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartPlaceholder('Bar Chart: Low/Medium/High', Colors.red),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHistoryItem(
          'Instagram',
          'Konten terdeteksi (Low)',
          '10:30',
          Colors.amber,
        ),
        _buildHistoryItem(
          'TikTok',
          'Diblokir (Medium)',
          '09:15',
          Colors.orange,
        ),
        _buildHistoryItem('YouTube', 'Aman', '08:45', Colors.green),
        _buildHistoryItem(
          'Browser',
          'Konten terdeteksi (High)',
          'Kemarin',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Pengaturan Khusus Anak',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        _buildSettingTile(
          'Screen Time Limit',
          'Batasi waktu penggunaan harian',
          Icons.timer,
          trailing: Text(
            '4 jam/hari',
            style: GoogleFonts.raleway(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        _buildSettingTile(
          'Notifikasi',
          'Terima alert real-time',
          Icons.notifications,
          trailing: Switch(
            value: true,
            onChanged: (val) {},
            activeThumbColor: const Color(0xFF4A90E2),
          ),
        ),

        const SizedBox(height: 32),

        // Danger Zone
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Zona Bahaya',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDisconnectDialog(),
                  icon: const Icon(Icons.link_off),
                  label: const Text('Putuskan Hubungan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Chip(
        label: Text(
          label,
          style: GoogleFonts.raleway(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: isSelected
            ? const Color(0xFF4A90E2)
            : const Color(0xFFF1F5F9),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(String label, Color color) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: color.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.raleway(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chart coming soon',
              style: GoogleFonts.raleway(
                color: const Color(0xFFCBD5E1),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String app,
    String status,
    String time,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.apps, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.raleway(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showDisconnectDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Putuskan Hubungan?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Data statistik ${widget.child.name} akan dihapus dan Anda tidak bisa lagi memantau aktivitas mereka.',
          style: GoogleFonts.raleway(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = Get.find<LinkController>();
              controller.disconnectChild(widget.child.id);
              Get.back(); // Close dialog
              Get.back(); // Back to dashboard
              Get.snackbar(
                'Terputus',
                'Hubungan dengan ${widget.child.name} telah diputus',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Putuskan'),
          ),
        ],
      ),
    );
  }
}
