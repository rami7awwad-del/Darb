import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:flutter/material.dart';

/// حوار متابعة الكورس: "أكمل الدرس السابق أولًا" عند الضغط على درس منتظر.
/// "ابدأ" يستدعي [onStart] (يفتح الدرس السابق)، و"إلغاء" يغلق الحوار فقط.
Future<void> showFinishPreviousDialog(
  BuildContext context, {
  required VoidCallback onStart,
}) async {
  final start = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.danger,
        size: 36,
      ),
      title: Text(
        'أكمل الدرس السابق أولًا',
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
          child: const Text('ابدأ'),
        ),
      ],
    ),
  );
  if (start == true) onStart();
}
