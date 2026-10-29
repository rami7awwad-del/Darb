import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/routing/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // الانتظار لمدة 3 ثوانٍ قبل التوجيه للشاشة القادمة
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // توكن محفوظ → الرئيسية، وإلا → تسجيل الدخول.
    // (انتهاء صلاحية التوكن يعالجه onUnauthorized في main.dart: يعيد إلى الدخول)
    final hasToken = context.read<StorageService>().hasToken;
    Navigator.pushReplacementNamed(
      context,
      hasToken ? AppRoutes.mainLayout : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // خلفية بيضاء نقية
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 224.48.w, // العرض الدقيق من Figma
          height: 209.h, // الارتفاع الدقيق من Figma
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
