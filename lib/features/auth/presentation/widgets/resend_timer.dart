import 'package:flutter/material.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// "لم تستلم الرمز؟ 00:55" + رابط "أعد إرسال الكود".
/// عند انتهاء العدّاد يظهر "الوقت أنتهى" ويُفعَّل الرابط.
class ResendTimer extends StatelessWidget {
  const ResendTimer({
    super.key,
    required this.secondsLeft,
    required this.onResend,
    this.isResending = false,
  });

  final int secondsLeft;
  final VoidCallback onResend;
  final bool isResending;

  bool get _finished => secondsLeft <= 0;

  String get _formatted {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _finished && !isResending;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            style: AppTextStyles.font12Regular.copyWith(color: AppColors.grey300),
            children: [
              const TextSpan(text: 'لم تستلم الرمز ؟ , '),
              _finished
                  ? TextSpan(
                      text: 'الوقت أنتهى',
                      style: AppTextStyles.font12Bold
                          .copyWith(color: AppColors.grey500),
                    )
                  : TextSpan(text: _formatted),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: canResend ? onResend : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'أعد إرسال الكود',
              // ⚠️ قياس تقديري: الرابط معطّل بلون رمادي أثناء العدّ
              style: AppTextStyles.font12Medium.copyWith(
                color: canResend ? AppColors.main600 : AppColors.grey200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
