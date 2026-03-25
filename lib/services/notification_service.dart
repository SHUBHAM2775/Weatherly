// ============================================================
// notification_service.dart
// Handles native system notifications for AQI alerts.
// Uses flutter_local_notifications for Android & iOS.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iOSPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iOSPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<bool> _hasPermission() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await androidPlugin?.areNotificationsEnabled();

    // If Android plugin exists, trust its permission status.
    if (androidGranted != null) return androidGranted;

    // For non-Android platforms, assume granted after iOS permission request.
    return true;
  }

  /// Show a high AQI alert notification (system tray style)
  Future<void> showHighAqiAlert({
    required int aqi,
    required int threshold,
    required String cityName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!await _hasPermission()) {
      await _requestPermissions();
      if (!await _hasPermission()) {
        debugPrint('Notifications permission denied; AQI alert not shown.');
        return;
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'aqi_alerts',
      'AQI Alerts',
      channelDescription: 'Notifications for high AQI levels',
      icon: 'app_icon',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 211, 47, 47),
      ledOnMs: 1000,
      ledOffMs: 3000,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0,
      'High AQI Alert',
      'AQI is $aqi in $cityName — above your alert threshold of $threshold',
      platformChannelSpecifics,
    );
  }

  /// Show a test notification (for Settings testing)
  Future<void> showTestNotification({
    required int testAqi,
    required int threshold,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!await _hasPermission()) {
      await _requestPermissions();
      if (!await _hasPermission()) {
        debugPrint('Notifications permission denied; test alert not shown.');
        return;
      }
    }

    final String message = testAqi >= threshold
        ? 'Test alert: AQI $testAqi exceeds threshold $threshold'
        : 'Test: AQI $testAqi is below threshold $threshold';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'aqi_alerts',
      'AQI Alerts',
      channelDescription: 'Notifications for high AQI levels',
      icon: 'app_icon',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      1,
      'Notification Test',
      message,
      platformChannelSpecifics,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  static void _onNotificationTapped(NotificationResponse details) {
    // Handle notification tap — e.g., navigate to AQI screen
    debugPrint('Notification tapped: ${details.payload}');
  }
}
