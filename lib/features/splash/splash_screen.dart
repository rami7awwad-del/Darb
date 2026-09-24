import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/style/app_colors.dart';

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

    // TODO: التوجيه للواجهة القادمة (مثل OnboardingView أو LoginView)
    // Navigator.pushReplacementNamed(context, Routes.onboardingView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // خلفية بيضاء نقية
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          width: 224.48.w,          // العرض الدقيق من Figma
          height: 209.h,             // الارتفاع الدقيق من Figma
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}