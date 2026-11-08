import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/routing/app_routes.dart';

/// Screen that shows the splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State for the splash screen widget.
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  /// Navigates to to next.
  void _navigateToNext() async {
    // Short pause so the logo stays visible.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // A saved token means the user can go straight to the home screen.
    final hasToken = context.read<StorageService>().hasToken;
    Navigator.pushReplacementNamed(
      context,
      hasToken ? AppRoutes.mainLayout : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 224.48.w,
          height: 209.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
