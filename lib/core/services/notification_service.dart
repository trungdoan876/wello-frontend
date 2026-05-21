import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/data_source/user_remote_data_source.dart';
import '../../domain/repositories/user_repository.dart';

// Background message handler - must be top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Thong bao nen duoc nhan!');
  print('Tieu de: ${message.notification?.title}');
  print('Noi dung: ${message.notification?.body}');
  print('Du lieu: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final UserRepository _userRepository =
      UserRepositoryImpl(userRemoteDataSource: UserRemoteDataSource());
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static bool _foregroundListenerAdded = false;

  /// Setup foreground message listener (call this in main.dart)
  static void setupForegroundListener() {
    print('Dang thiet lap lang nghe FCM o foreground...');

    // Setup foreground message handler to show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('----------------------------------------');
      print('NHAN DUOC THONG BAO O FOREGROUND!');
      print('Thong bao: ${message.notification}');
      print('Tieu de: ${message.notification?.title}');
      print('Noi dung: ${message.notification?.body}');
      print('Du lieu: ${message.data}');
      print('----------------------------------------');

      // Get title and body from notification or data
      final title =
          message.notification?.title ?? message.data['title'] ?? 'Thông báo';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      print('Dang hien thi thong bao noi bo: $title - $body');

      // Show local notification
      showLocalNotification(title, body);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Nguoi dung nhan vao thong bao (app dang o nen)');
      print('Du lieu: ${message.data}');
      // Handle navigation based on notification data
    });

    print('Thiet lap lang nghe FCM foreground hoan tat!');
  }

  /// Initialize notification service (call this after user login)
  static Future<void> initialize(int userId, String authToken) async {
    if (_isInitialized) {
      return;
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Create notification channel for Android 8+
    const androidChannel = AndroidNotificationChannel(
      'water_reminder_channel',
      'Nhắc nhở uống nước',
      description: 'Thông báo nhắc nhở uống nước',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Request permission for Android 13+ and iOS
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get FCM Token
    String? fcmToken = await _messaging.getToken();

    if (fcmToken != null) {
      print('------------------------------------------------');
      print('FCM TOKEN:');
      print(fcmToken);
      print('------------------------------------------------');

      try {
        await _userRepository.updateFcmToken(
          authToken,
          fcmToken,
        );
        print('Cap nhat FCM Token len backend thanh cong');
      } catch (e) {
        print('Loi cap nhat FCM Token len backend: $e');
      }
    } else {
      print('Khong the lay FCM token');
    }

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!_foregroundListenerAdded) {
      // Setup foreground message handler to show local notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('----------------------------------------');
        print('NHAN DUOC THONG BAO FOREGROUND!');
        print('Thong bao: ${message.notification}');
        print('Tieu de: ${message.notification?.title}');
        print('Noi dung: ${message.notification?.body}');
        print('Du lieu: ${message.data}');
        print('----------------------------------------');

        // Get title and body from notification or data
        final title =
            message.notification?.title ?? message.data['title'] ?? 'Thông báo';
        final body = message.notification?.body ?? message.data['body'] ?? '';

        print('Dang hien thi thong bao noi bo: $title - $body');

        // Show local notification
        showLocalNotification(title, body);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Nguoi dung nhan vao thong bao (app dang o nen)');
        print('Du lieu: ${message.data}');
        // Handle navigation based on notification data
      });

      _foregroundListenerAdded = true;
    }

    _isInitialized = true;
  }

  /// Show local notification in system tray
  static Future<void> showLocalNotification(String title, String body) async {
    print('showLocalNotification duoc goi voi: $title - $body');
    try {
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
    } catch (e) {
      print('Loi khi hien thi thong bao noi bo: $e');
    }
  }

  /// Background message handler (must be top-level function)
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('Thong bao nen duoc nhan!');
    print('Tieu de: ${message.notification?.title}');
    print('Noi dung: ${message.notification?.body}');
    // Background messages are automatically shown by FCM
  }

  /// Setup foreground notification listener (deprecated - now using local notifications)
  static void setupForegroundHandler(BuildContext context) {
    // No longer needed - notifications are shown via local notifications
  }
}
