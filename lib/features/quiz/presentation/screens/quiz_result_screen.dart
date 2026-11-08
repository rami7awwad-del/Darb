import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';

/// Screen that shows the quiz result.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.outcome});

  final QuizOutcome outcome;

  String get _message {
    final p = outcome.percent;
    if (p >= 80) return 'لقد حققت نتيجة رائعة، استمر في هذا الأداء المتميز.';
    if (p >= 50) return 'نتيجة جيدة، راجع أجوبتك لتحسّنها أكثر.';
    return 'لا بأس، راجع أجوبتك وحاول مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 56.h),
                      Container(
                        width: 112.w,
                        height: 112.w,
                        decoration: const BoxDecoration(
                          color: AppColors.main500,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.military_tech_rounded,
                          size: 60.w,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'تم إنهاء الاختبار بنجاح!',
                        style: AppTextStyles.font20Bold.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Regular.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '${outcome.percent}%',
                        style: AppTextStyles.font49Medium.copyWith(
                          color: AppColors.second500,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        spacing: 12.w,
                        children: [
                          _StatCard(
                            icon: Icons.help_outline_rounded,
                            color: AppColors.second500,
                            value: outcome.total,
                            label: 'عدد الأسئلة',
                          ),
                          _StatCard(
                            icon: Icons.check_circle_rounded,
                            color: AppColors.main600,
                            value: outcome.correct,
                            label: 'الأجوبة الصح',
                          ),
                          _StatCard(
                            icon: Icons.cancel_rounded,
                            color: AppColors.danger,
                            value: outcome.wrong,
                            label: 'الأجوبة الخطأ',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppPrimaryButton(
                text: 'تأكد من الأجوبة',
                icon: Icon(
                  Icons.fact_check_outlined,
                  size: 18.w,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.quizReview,
                  arguments: outcome,
                ),
              ),
              SizedBox(height: 12.h),
              AppOutlineButton(
                text: 'الرجوع للصفحة الرئيسية',
                icon: Icon(Icons.home_outlined, size: 18.w),
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName(AppRoutes.mainLayout),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for the stat.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey50),
        ),
        child: Column(
          spacing: 8.h,
          children: [
            Icon(icon, size: 28.w, color: color),
            Text(
              '$value',
              style: AppTextStyles.font16Bold.copyWith(
                color: AppColors.grey700,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.grey300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
