import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// قائمة منسدلة بنفس شكل [AppTextField] (ارتفاع 52، Radius 11، Border 1px).
/// ملاحظة: إن اشتكى المحلّل من `initialValue` في إصدار Flutter عندك فاستبدلها بـ `value`.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.prefixIcon,
    this.validator,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String? hint;
  final Widget? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      isDense: true,
      menuMaxHeight: 300.h,
      borderRadius: BorderRadius.circular(11.r),
      dropdownColor: AppColors.white,
      icon: Padding(
        padding: EdgeInsetsDirectional.only(end: 13.w),
        child: Icon(
          PhosphorIconsRegular.caretDown,
          size: 18.w,
          color: AppColors.main600,
        ),
      ),
      style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey500),
      hint: hint == null
          ? null
          : Text(
              hint!,
              style: AppTextStyles.font14Regular
                  .copyWith(color: AppColors.grey200),
            ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: EdgeInsetsDirectional.only(
          top: 16.h,
          bottom: 16.h,
          start: prefixIcon == null ? 28.w : 0,
          end: 0,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: EdgeInsetsDirectional.only(start: 28.w, end: 5.w),
                child: IconTheme(
                  data: IconThemeData(color: AppColors.main600, size: 20.w),
                  child: prefixIcon!,
                ),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        errorStyle:
            AppTextStyles.font12Regular.copyWith(color: AppColors.danger),
        enabledBorder: _border(AppColors.grey100),
        focusedBorder: _border(AppColors.main600),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger),
      ),
    );
  }
}
