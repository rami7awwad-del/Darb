import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// الترويسة التركوازية المشتركة (Figma: 433×227، الشعار 121.37×113).
/// [showBack] يعرض سهم الرجوع في بداية الترويسة (يمين في RTL).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // أيقونات شريط الحالة بيضاء فوق التركوازي
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        height: 227.h,
        decoration: BoxDecoration(
          // ⚠️ قياس تقديري: لون الخلفية (main600) ونصف قطر الحواف السفلية (32)
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
                height: 113.h,
                fit: BoxFit.contain,
              ),
              if (showBack)
                PositionedDirectional(
                  // ⚠️ قياس تقديري: موضع السهم (24 من الحافة، 12 من الأعلى)
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

/// البطاقة البيضاء المشتركة (Figma: 405 عرض، Radius 24، حد 1px #DBDBDB،
/// Padding 26 عمودي × 31 أفقي، Gap 18).
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// عنوان البطاقة بلونين: [first] بلون main و[second] بلون second.
/// ⚠️ قياس تقديري: أي كلمات تأخذ أي لون (تحقق من Figma).
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.first, required this.second});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    // Figma: 32، والمقياس المعتمد 31، فنستخدم 32 كما في التصميم.
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
