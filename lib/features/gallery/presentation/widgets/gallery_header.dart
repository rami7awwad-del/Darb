import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// الشريط التركوازي العلوي للمعرض: العنوان في الوسط، وزر الإشعارات في النهاية،
/// وفي البداية شعار الكتاب المفتوح، أو سهم رجوع إن مُرّر [onBack] (شاشة الألبوم).
/// ⚠️ قياس تقديري: حجم عناصر الصف (36)، الحشوات، نصف قطر الحواف (32)،
/// حجم الشعار (36)، حجم سهم الرجوع (24). الحشوات والحواف مأخوذة من HomeHeader.
class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    super.key,
    this.onBack,
    this.onNotifications,
    this.title = 'المعرض',
    this.icon = PhosphorIconsRegular.image,
  });

  /// عنوان الشريط (الافتراضي: المعرض). تستخدمه أيضًا صفحة "موادي".
  final String title;
  final IconData icon;

  /// إن كان null يظهر الشعار بدل سهم الرجوع.
  final VoidCallback? onBack;
  final VoidCallback? onNotifications;

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
            child: SizedBox(
              height: 36.w,
              child: Row(
                children: [
                  _Leading(onBack: onBack),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 20.w,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          title,
                          style: AppTextStyles.font16Medium
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  _BellButton(onTap: onNotifications),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
              // arrow_back ينعكس تلقائيًا في RTL فيشير لليمين (رجوع).
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.w,
                color: AppColors.white,
              ),
            ),
    );
  }
}

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
