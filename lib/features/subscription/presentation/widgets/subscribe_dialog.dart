import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Shows subscribe dialog.
Future<bool> showSubscribeDialog(
  BuildContext context, {
  String title = 'اشترك الآن واحصل عليه',
}) async {
  final subscribe = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      icon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.main600,
        size: 36,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.font16Medium.copyWith(color: AppColors.grey700),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.main600),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('اشترك'),
        ),
      ],
    ),
  );
  if (subscribe != true) return false;
  final done = await navigatorKey.currentState
      ?.pushNamed<bool>(AppRoutes.subscription);
  return done ?? false;
}
