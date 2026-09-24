import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// طلب الصلاحيات وجلب FCM Token لإرساله مع طلب التفعيل
  Future<String?> getFcmToken() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $token');
        return token;
      } else {
        debugPrint('Notification permissions denied');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
    return null;
  }

  /// الاستماع للإشعارات أثناء فتح التطبيق (Foreground)
  void listenToForegroundNotifications({
    void Function(RemoteMessage message)? onMessage,
  }) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message Title: ${message.notification?.title}');
      debugPrint('Foreground Message Body: ${message.notification?.body}');
      if (onMessage != null) {
        onMessage(message);
      }
    });
  }

  /// التعامل مع النقر على الإشعار عند التفاعل معه
  void setupNotificationTapHandler({
    void Function(RemoteMessage message)? onNotificationTap,
  }) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked with data: ${message.data}');
      if (onNotificationTap != null) {
        onNotificationTap(message);
      }
    });
  }
}