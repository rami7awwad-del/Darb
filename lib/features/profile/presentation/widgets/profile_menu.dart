import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// Widget that shows the profile menu title.
class ProfileMenuTitle extends StatelessWidget {
  const ProfileMenuTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Text(
        text,
        style: AppTextStyles.font16Medium.copyWith(color: AppColors.grey500),
      ),
    );
  }
}

/// List tile widget for the profile menu.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(icon, size: 24.w, color: AppColors.second500),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20.w,
                  color: AppColors.grey200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
