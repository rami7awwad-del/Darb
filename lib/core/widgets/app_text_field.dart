import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// Text field styled for the app.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? hint;

  final Widget? prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  final int? minLines;
  final int? maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

/// State for the app text field widget.
class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      minLines: widget.isPassword ? 1 : widget.minLines,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      cursorColor: AppColors.main600,
      style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey500),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle:
            AppTextStyles.font14Regular.copyWith(color: AppColors.grey200),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: EdgeInsetsDirectional.only(
          top: 16.h,
          bottom: 16.h,
          start: widget.prefixIcon == null ? 28.w : 0,
          end: 13.w,
        ),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Padding(
                padding: EdgeInsetsDirectional.only(start: 28.w, end: 5.w),
                child: IconTheme(
                  data: IconThemeData(color: AppColors.main600, size: 20.w),
                  child: widget.prefixIcon!,
                ),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.w,
                  color: AppColors.main600,
                ),
              )
            : null,
        errorStyle:
            AppTextStyles.font12Regular.copyWith(color: AppColors.danger),
        enabledBorder: _border(AppColors.grey100),
        disabledBorder: _border(AppColors.grey100),
        focusedBorder: _border(AppColors.main600),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger),
      ),
    );
  }
}
