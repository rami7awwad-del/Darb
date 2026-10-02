import 'package:flutter/material.dart';

/// مفتاح Navigator عام، يُستخدم للتنقل من خارج الـ Widgets
/// (مثل إعادة المستخدم لشاشة الدخول عند انتهاء التوكن من DioFactory).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
