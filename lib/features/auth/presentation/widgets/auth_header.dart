import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_responsive.dart';

/// Header widget for the auth.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    // Use a shorter header in landscape.
    final landscape = isLandscapeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        height: landscape ? 140.h : 227.h,
        decoration: BoxDecoration(
          color: AppColors.main600,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/logo1.png',
                width: 121.37.w,
                height: landscape ? 78.h : 113.h,
                fit: BoxFit.contain,
              ),
              if (showBack)
                PositionedDirectional(
                  start: 24.w,
                  top: 12.h,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 24.w,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for the auth.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Keep the card readable on wide screens.
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 31.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 18.h,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Two color title used on the auth cards.
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.first, required this.second});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.font31Medium.copyWith(fontSize: 32.sp);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$first ', style: base.copyWith(color: AppColors.main600)),
          TextSpan(text: second, style: base.copyWith(color: AppColors.second500)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
