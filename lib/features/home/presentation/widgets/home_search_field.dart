import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// حقل البحث (أيقونة البحث في النهاية = يسار في RTL، كما في Figma).
/// ⚠️ قياس تقديري: الارتفاع (≈ 48 من الحشوات) ولون الأيقونة (second500).
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.main600,
      style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey500),
      decoration: InputDecoration(
        hintText: 'أبحث هنا...',
        hintStyle:
            AppTextStyles.font14Regular.copyWith(color: AppColors.grey200),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding:
            EdgeInsetsDirectional.only(start: 16.w, end: 12.w, top: 14.h, bottom: 14.h),
        suffixIcon: Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 20.w,
            color: AppColors.second500,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: _border(const Color(0xFFDBDBDB)),
        focusedBorder: _border(AppColors.main600),
      ),
    );
  }
}
