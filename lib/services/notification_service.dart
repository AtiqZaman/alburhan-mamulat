import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    tz_data.initializeTimeZones();

    try {
      // Android initialization with fallback icon
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS initialization (onDidReceiveLocalNotification removed in v18)
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Handle notification tap
        },
      );
    } catch (e) {
      print('Error initializing notifications: $e');
      // Continue app even if notifications fail to initialize
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Disabled due to Flutter/Firebase compatibility issue
    // Will be re-enabled in future release
    return;
  }

  // Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    // Disabled due to Flutter/Firebase compatibility issue
    return;
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Send task reminder for Salik
  Future<void> sendTaskReminder({
    required String salikName,
    required int day,
    required int level,
  }) async {
    await showNotification(
      id: 100,
      title: 'Daily Task Reminder',
      body: 'Hi $salikName, it\'s time to complete your daily tasks for Day $day (Level $level)',
      payload: 'salik_task_reminder',
    );
  }

  // Send new update notification for Murabi
  Future<void> sendUpdateNotification({
    required String salikName,
    required String murabiName,
  }) async {
    await showNotification(
      id: 200,
      title: 'New Update from Salik',
      body: '$salikName has submitted their daily update',
      payload: 'murabi_new_update',
    );
  }

  // Send level progression notification
  Future<void> sendLevelProgressionNotification({
    required String salikName,
    required int newLevel,
  }) async {
    await showNotification(
      id: 300,
      title: 'Level Complete!',
      body: 'Congratulations $salikName! You\'ve progressed to Level $newLevel',
      payload: 'level_progression',
    );
  }

  // Schedule daily task reminders
  Future<void> setupDailyTaskReminder({
    required int hour,
    required int minute,
    required String salikName,
  }) async {
    await scheduleDailyNotification(
      id: 1000,
      title: 'Complete Your Daily Tasks',
      body: 'Good morning $salikName! Time to complete your spiritual practices.',
      hour: hour,
      minute: minute,
      payload: 'daily_task_reminder',
    );
  }
}
