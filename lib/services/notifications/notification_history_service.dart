import 'package:flutter/material.dart';

class NotificationHistoryService {
  static final NotificationHistoryService _instance =
      NotificationHistoryService._internal();
  factory NotificationHistoryService() => _instance;
  NotificationHistoryService._internal();

  // In-memory notification storage (in production, use database like SQLite)
  static final List<Map<String, dynamic>> _notifications = [];

  // Get all notifications
  List<Map<String, dynamic>> getAllNotifications() {
    return List.from(_notifications.reversed); // Show newest first
  }

  // Add new notification
  void addNotification({
    required String title,
    required String message,
    required String type, // 'threat', 'warning', 'info'
    required String level, // 'low', 'medium', 'high'
    required String app,
    String? action,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'time': _formatTime(DateTime.now()),
      'date': _formatDate(DateTime.now()),
      'type': type,
      'level': level,
      'icon': _getIconForType(type),
      'color': _getColorForLevel(level),
      'isRead': false,
      'app': app,
      'action': action,
      'timestamp': DateTime.now(),
    };

    _notifications.add(notification);

    // Keep only last 100 notifications to prevent memory issues
    if (_notifications.length > 100) {
      _notifications.removeAt(0);
    }
  }

  // Mark notification as read
  void markAsRead(int id) {
    int index = _notifications.indexWhere((notif) => notif['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => !n['isRead']).length;
  }

  // Get today's notifications count
  int getTodayCount() {
    final today = _formatDate(DateTime.now());
    return _notifications.where((n) => n['date'] == today).length;
  }

  // Get threat notifications count
  int getThreatCount() {
    return _notifications.where((n) => n['level'] == 'high').length;
  }

  // Helper methods
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'threat':
        return Icons.dangerous;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'monitoring':
        return Icons.security;
      case 'block':
        return Icons.block;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to add threat notification with detection tracking
  void addThreatNotification({
    required String threatLevel,
    required String appName,
    required String contentType,
    String? action,
  }) {
    String title;
    String message;
    String type = 'threat';
    String finalAction;

    // Determine action based on threat level if not provided
    if (action == null) {
      switch (threatLevel) {
        case 'high':
          finalAction = 'Aplikasi diblokir';
          break;
        case 'medium':
          finalAction = 'Peringatan ditampilkan';
          break;
        case 'low':
          finalAction = 'Konten terdeteksi';
          break;
        default:
          finalAction = 'Monitoring';
      }
    } else {
      finalAction = action;
    }

    switch (threatLevel) {
      case 'low':
        title = 'Deteksi Ringan';
        message = '$appName: $contentType terdeteksi';
        type = 'warning';
        break;
      case 'medium':
        title = 'Peringatan Sedang';
        message = '$appName: $contentType - Waspada!';
        type = 'warning';
        break;
      case 'high':
        title = 'Ancaman Tinggi';
        message = '$appName: $contentType - Aplikasi diblokir!';
        type = 'threat';
        break;
      default:
        title = 'Deteksi Konten';
        message = '$appName: $contentType';
        type = 'info';
    }

    addNotification(
      title: title,
      message: message,
      type: type,
      level: threatLevel,
      app: appName,
      action: finalAction,
    );
  }

  // Helper method to add monitoring status notification
  void addMonitoringNotification({required bool isActive}) {
    addNotification(
      title: isActive ? 'Monitoring Dimulai' : 'Monitoring Dihentikan',
      message: isActive
          ? 'Sistem monitoring parental control telah aktif.'
          : 'Sistem monitoring parental control dihentikan.',
      type: 'info',
      level: 'low',
      app: 'System',
      action: isActive ? 'start_monitoring' : 'stop_monitoring',
    );
  }
}
