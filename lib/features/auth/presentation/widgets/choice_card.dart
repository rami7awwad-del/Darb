import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

const Color _borderColor = Color(0xFFDBDBDB);

/// Card widget for the choice.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.large = false,
    this.boxedIcon = true,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;
  final bool large;
  final bool boxedIcon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);
    final boxSize = (large ? 48 : 40).w;

    final Widget iconWidget = boxedIcon
        ? Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: selected ? AppColors.main50 : AppColors.second50,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              size: boxSize * 0.5,
              color: selected ? AppColors.main600 : AppColors.second500,
            ),
          )
        : Icon(
            icon,
            size: 24.w,
            color: selected ? AppColors.main600 : AppColors.grey400,
          );

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppColors.main600 : _borderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: (large ? 20 : 14).h,
                  horizontal: 16.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    SizedBox(height: (large ? 12 : 6).h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: (large
                              ? AppTextStyles.font20Medium
                              : AppTextStyles.font14Medium)
                          .copyWith(color: AppColors.grey500),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font12Regular
                            .copyWith(color: AppColors.grey400),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (selected)
              PositionedDirectional(
                top: 10.h,
                end: 10.w,
                child: Icon(
                  PhosphorIconsRegular.checkCircle,
                  size: 18.w,
                  color: AppColors.main600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// List tile widget for the choice.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);

    return SizedBox(
      height: 72.h,
      child: Material(
        color: selected ? AppColors.second300 : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.second300 : _borderColor,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: selected
                ? Icon(
                    PhosphorIconsFill.checkCircle,
                    size: 30.w,
                    color: AppColors.white,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22.w, color: AppColors.second500),
                      SizedBox(height: 6.h),
                      Text(
                        label,
                        style: AppTextStyles.font12Regular
                            .copyWith(color: AppColors.grey400),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
