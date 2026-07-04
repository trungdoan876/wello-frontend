import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:wello_frontend/firebase_options.dart';
import 'notification_service.dart';

class FirebaseService {
  static Future<void> initialize() async {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Setup background message handler TRƯỚC KHI app chạy
    FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler,
    );

    // Setup foreground message listener
    NotificationService.setupForegroundListener();
  }

  /// Get navigator key cho Firebase notifications
  static GlobalKey<NavigatorState> get navigatorKey {
    return NotificationService.navigatorKey;
  }
}
