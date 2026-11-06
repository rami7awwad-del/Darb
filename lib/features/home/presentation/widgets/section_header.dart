import 'package:flutter/material.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// Header widget for the section.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.second500,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.font16Medium.copyWith(color: color),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              actionLabel!,
              style: AppTextStyles.font12Regular.copyWith(color: color),
            ),
          ),
      ],
    );
  }
}
