import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'notification_history_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request notification permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // For Android 13+, request POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Real-time threat detection notifications',
          importance: importance,
          priority: priority,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          styleInformation: const BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showThreatNotification({
    required String threatLevel,
    required String appName,
    required String contentType,
  }) async {
    String title;
    String body;
    Importance importance;
    Priority priority;

    switch (threatLevel) {
      case 'low':
        title = '⚠️ Deteksi Ringan';
        body = '$appName: $contentType terdeteksi';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case 'medium':
        title = '🔶 Peringatan Sedang';
        body = '$appName: $contentType - Waspada!';
        importance = Importance.high;
        priority = Priority.high;
        break;
      case 'high':
        title = '🔴 Ancaman Tinggi';
        body = '$appName: $contentType - Segera tutup!';
        importance = Importance.max;
        priority = Priority.max;
        break;
      case 'critical':
        title = '🚨 BAHAYA KRITIS!';
        body = '$appName: $contentType - NSFW TERDETEKSI!';
        importance = Importance.max;
        priority = Priority.max;
        break;
      default:
        title = '✅ Sistem Aman';
        body = 'Monitoring berjalan normal';
        importance = Importance.low;
        priority = Priority.low;
    }

    // Store in notification history
    NotificationHistoryService().addThreatNotification(
      threatLevel: threatLevel,
      appName: appName,
      contentType: contentType,
      action: threatLevel == 'high'
          ? 'Aplikasi di Blokir'
          : 'Peringatan Ditampilkan',
    );

    // Create custom notification channel for threats
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'threat_notifications',
          'Threat Alerts',
          channelDescription: 'Critical threat detection alerts',
          importance: importance,
          priority: priority,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Paradise Security',
          ),
          color: Color(_getThreatColor(threatLevel) ?? 0xFF10B981),
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: 'threat:$threatLevel:$appName',
    );
  }

  Future<void> showMonitoringStatusNotification({
    required bool isActive,
  }) async {
    String title = isActive
        ? '🛡️ Monitoring Aktif'
        : '⏹️ Monitoring Dihentikan';
    String body = isActive
        ? 'Sistem sedang memantau konten berbahaya secara real-time'
        : 'Perlindungan real-time telah dinonaktifkan';

    // Store in notification history
    NotificationHistoryService().addMonitoringNotification(isActive: isActive);

    await showInstantNotification(
      title: title,
      body: body,
      importance: isActive ? Importance.defaultImportance : Importance.low,
      priority: isActive ? Priority.defaultPriority : Priority.low,
      payload: 'monitoring:${isActive ? 'started' : 'stopped'}',
    );
  }

  // Helper method to get color based on threat level
  int? _getThreatColor(String threatLevel) {
    switch (threatLevel) {
      case 'low':
        return 0xFF10B981; // Green
      case 'medium':
        return 0xFFEA580C; // Orange
      case 'high':
        return 0xFFDC2626; // Red
      case 'critical':
        return 0xFF7C3AED; // Purple
      default:
        return 0xFF10B981; // Green
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
