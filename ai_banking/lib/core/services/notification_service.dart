import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permission');
        }
        
        final token = await _messaging.getToken();
        if (kDebugMode) {
          print('FCM Token: $token');
        }
      }
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Handling a foreground message: ${message.messageId}');
        }
        // Handle foreground message
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  static Future<void> showTransactionNotification({
    required String title,
    required String body,
  }) async {
    if (kDebugMode) {
      print('NOTIFICATION [$title]: $body');
    }
    // Implement local notifications if needed
  }
}
