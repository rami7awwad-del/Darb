import 'dart:async';
import 'dart:io';

import 'package:darb/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    debugPrint('Background message received: ${message.messageId}');
    debugPrint('Background message data: ${message.data}');
  }
}

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  Future<void> init() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (kDebugMode) {
          debugPrint('Notification permissions denied, trying token anyway.');
        }
      }

      if (Platform.isIOS) {
        for (var attempt = 0; attempt < 3; attempt++) {
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken != null) {
            break;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting FCM token: $e');
      }
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  Future<RemoteMessage?> getInitialMessage() async {
    return _firebaseMessaging.getInitialMessage();
  }

  void listenToForegroundNotifications({
    void Function(RemoteMessage message)? onMessage,
  }) {
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground Message Title: ${message.notification?.title}');
        debugPrint('Foreground Message Body: ${message.notification?.body}');
      }

      // TODO: show a local notification on Android when the app is in the foreground.
      onMessage?.call(message);
    });
  }

  void setupNotificationTapHandler({
    void Function(RemoteMessage message)? onNotificationTap,
  }) {
    _messageOpenedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Notification clicked with data: ${message.data}');
      }
      onNotificationTap?.call(message);
    });
  }

  void dispose() {
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
  }
}