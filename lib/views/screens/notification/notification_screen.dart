import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/notifications/notification_history_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationHistoryService _historyService =
      NotificationHistoryService();
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      notifications = _historyService.getAllNotifications();

      // If no notifications exist, add some sample ones for demo
      if (notifications.isEmpty) {
        _addSampleNotifications();
        notifications = _historyService.getAllNotifications();
      }
    });
  }

  void _addSampleNotifications() {
    // High Risk Notifications
    _historyService.addThreatNotification(
      threatLevel: 'high',
      appName: 'TikTok',
      contentType: 'Konten Dewasa Eksplisit',
      action: 'Aplikasi Diblokir Otomatis',
    );

    _historyService.addThreatNotification(
      threatLevel: 'high',
      appName: 'Instagram',
      contentType: 'Percakapan Mencurigakan',
      action: 'Konten Diblokir',
    );

    // Medium Risk Notifications
    _historyService.addThreatNotification(
      threatLevel: 'medium',
      appName: 'YouTube',
      contentType: 'Video Konten Dewasa',
      action: 'Popup Peringatan Ditampilkan',
    );

    _historyService.addThreatNotification(
      threatLevel: 'medium',
      appName: 'TikTok',
      contentType: 'Komentar Tidak Pantas',
      action: 'Warning Diberikan',
    );

    // Low Risk Notifications
    _historyService.addThreatNotification(
      threatLevel: 'low',
      appName: 'Instagram',
      contentType: 'Thumbnail Kurang Pantas',
      action: 'Konten Terdeteksi, Tidak Diblokir',
    );

    _historyService.addThreatNotification(
      threatLevel: 'low',
      appName: 'YouTube',
      contentType: 'Kata Kunci Sensitif',
      action: 'Dipantau',
    );

    // System Notifications
    _historyService.addMonitoringNotification(isActive: true);

    // Additional monitoring notification
    _historyService.addThreatNotification(
      threatLevel: 'medium',
      appName: 'System',
      contentType: 'Percobaan Akses Aplikasi Terlarang',
      action: 'Akses Ditolak',
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return const Color(0xFFEAB308); // Yellow for consistency
      default:
        return Colors.grey;
    }
  }

  String _getLevelLabel(String level) {
    switch (level) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  String _getTimeAgo(String date, String time) {
    // Simple time ago calculation for demo
    if (date == '15 Sep 2024') {
      return 'Hari ini';
    } else if (date == '14 Sep 2024') {
      return 'Kemarin';
    }
    return date;
  }

  IconData _getAppIcon(String app) {
    switch (app.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_fill;
      case 'instagram':
        return Icons.camera_alt;
      case 'tiktok':
        return Icons.music_note;
      case 'system':
        return Icons.security;
      default:
        return Icons.apps;
    }
  }

  Color _getAppColor(String app) {
    switch (app.toLowerCase()) {
      case 'youtube':
        return Colors.red;
      case 'instagram':
        return Colors.purple;
      case 'tiktok':
        return Colors.black;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _markAsRead(int id) {
    _historyService.markAsRead(id);
    _loadNotifications();
  }

  void _markAllAsRead() {
    _historyService.markAllAsRead();
    _loadNotifications();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Semua Notifikasi',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus semua notifikasi?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _historyService.clearAll();
                _loadNotifications();
                Navigator.of(context).pop();
              },
              child: Text('Hapus', style: GoogleFonts.inter(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi',
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount notifikasi belum dibaca',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Baca Semua',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAll();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus Semua',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Summary header
                if (notifications.isNotEmpty) _buildSummaryHeader(),
                // Notifications list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(notifications[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua notifikasi akan muncul di sini',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final unreadCount = _historyService.getUnreadCount();
    final todayCount = _historyService.getTodayCount();
    final threatCount = _historyService.getThreatCount();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Notifikasi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${notifications.length} total notifikasi',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Belum Dibaca',
                  '$unreadCount',
                  Colors.orange.shade700,
                  Icons.mark_email_unread,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  'Hari Ini',
                  '$todayCount',
                  Colors.blue.shade700,
                  Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  'Ancaman',
                  '$threatCount',
                  Colors.red.shade700,
                  Icons.shield_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () => _markAsRead(notification['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['isRead'] ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification['isRead']
                ? Colors.grey.shade200
                : Colors.blue.shade200,
            width: notification['isRead'] ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan waktu dan level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!notification['isRead'])
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      '${notification['time']} • ${_getTimeAgo(notification['date'], notification['time'])}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(notification['level']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getLevelLabel(notification['level']),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAppColor(notification['app']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAppIcon(notification['app']),
                    color: _getAppColor(notification['app']),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            notification['icon'],
                            size: 16,
                            color: notification['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification['app'],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: notification['color'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
