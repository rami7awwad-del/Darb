import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// Header widget for the gallery.
class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    super.key,
    this.onBack,
    this.onNotifications,
    this.title = 'المعرض',
    this.icon = PhosphorIconsRegular.image,
    this.bottom,
    this.trailing,
  });

  final String title;
  final IconData? icon;

  final VoidCallback? onBack;
  final VoidCallback? onNotifications;

  final Widget? bottom;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.main600,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            SizedBox(
              height: 36.w,
              child: Row(
                children: [
                  _Leading(onBack: onBack),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 20.w,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          title,
                          style: AppTextStyles.font16Medium
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    SizedBox(width: 36.w, height: 36.w, child: trailing)
                  else
                    _BellButton(
                      onTap: onNotifications ??
                          () => Navigator.pushNamed(
                                context,
                                AppRoutes.notifications,
                              ),
                    ),
                ],
              ),
            ),
                if (bottom != null) ...[
                  SizedBox(height: 16.h),
                  bottom!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small private widget used only in this file.
class _Leading extends StatelessWidget {
  const _Leading({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      height: 36.w,
      child: onBack == null
          ? Image.asset('assets/images/logo1.png', fit: BoxFit.contain)
          : InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.w,
                color: AppColors.white,
              ),
            ),
    );
  }
}

/// Button widget for the bell.
class _BellButton extends StatelessWidget {
  const _BellButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);
    return Material(
      color: AppColors.second500,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Icon(
            PhosphorIconsRegular.bell,
            size: 20.w,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
