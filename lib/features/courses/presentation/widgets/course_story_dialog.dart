import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// نافذة التعريف بالدورة: صورتها ونصها من `story_image` و`story_text`، وزر "ابدأ الآن".
/// تظهر عندما يرجع courses/details بـ `is_first_story = true`.
Future<void> showCourseStory(
  BuildContext context, {
  String? imageUrl,
  String? text,
  required VoidCallback onStart,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h), // 📏
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r), // 📏
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 341 / 300,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.main50),
                ),
              ),
            if (text != null && text.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0), // 📏
                child: Text(
                  text.trim(),
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.main700,
                    height: 1.5,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h), // 📏
              child: AppPrimaryButton(
                text: 'ابدأ الآن',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onStart();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
