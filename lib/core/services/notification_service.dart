import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/repositories/profile_repository.dart';

// Background message handler - must be top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background message received!');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final ProfileRepository _profileRepository = ProfileRepository();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(int userId) async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);
    // Request permission for Android 13+ and iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM Token
    String? token = await _messaging.getToken();
    
    if (token != null) {
      print('================================================');
      print('🚀 FCM TOKEN:');
      print(token);
      print('================================================');
      
      try {
        await _profileRepository.updateFcmToken(
          userId: userId,
          fcmToken: token,
        );
        print('✅ FCM Token updated on backend');
      } catch (e) {
        print('❌ Failed to update FCM Token on backend: $e');
      }
    } else {
      print('⚠️ Failed to get FCM token');
    }

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup foreground message handler to show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Foreground message received!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      
      // Show local notification
      _showLocalNotification(
        message.notification?.title ?? 'Thông báo',
        message.notification?.body ?? '',
      );
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification tapped (app was in background)');
      print('Data: ${message.data}');
      // Handle navigation based on notification data
    });
  }

  /// Show local notification in system tray
  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Nhắc nhở uống nước',
      channelDescription: 'Thông báo nhắc nhở uống nước',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/notification_icon'),
      color: Color(0xFF61C8F5), // Water blue color
      colorized: true,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// Setup foreground notification listener (deprecated - now using local notifications)
  static void setupForegroundHandler(BuildContext context) {
    // No longer needed - notifications are shown via local notifications
  }
}
