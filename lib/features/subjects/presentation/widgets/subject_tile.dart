import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/home/data/models/subject_model.dart';

/// عنصر في شبكة "كل الفئات": شارة زرقاء باسم المادة فوق صورتها.
/// 📏 ارتفاع الشارة 40، Radius 8، حجم الصورة 64، المسافة بينهما 8
/// (قياسات الرئيسية كانت 32 و60، وهنا الشارة أكبر حسب Figma).
class SubjectTile extends StatelessWidget {
  const SubjectTile({super.key, required this.subject, required this.onTap});

  final SubjectModel subject;
  final VoidCallback onTap;

  /// الارتفاع الكلي للعنصر (يستخدمه mainAxisExtent في الشبكة).
  static double get height => 40.h + 8.h + 64.w; // 📏

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r), // 📏
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40.h, // 📏
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 6.w), // 📏
            decoration: BoxDecoration(
              color: AppColors.second500,
              borderRadius: BorderRadius.circular(8.r), // 📏
            ),
            child: Text(
              subject.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: 8.h), // 📏
          AppNetworkImage(
            url: subject.image,
            width: 64.w, // 📏
            height: 64.w, // 📏
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
