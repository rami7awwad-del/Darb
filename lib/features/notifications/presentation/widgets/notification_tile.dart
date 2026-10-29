import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';

/// عنصر إشعار: أيقونة دائرية في البداية (اليمين)، ثم العنوان والتاريخ والنص.
/// ⚠️ قياس تقديري من لقطة Figma: حجم الدائرة (48)، الحشوات (16/20)، الفواصل (4/12).
/// الـ API لا يعيد نوع الإشعار ولا صورة، لذلك الأيقونة موحّدة (مكبّر صوت).
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h), // 📏
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w, // 📏
        children: [
          Container(
            width: 48.w, // 📏
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.midGrey,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 26.w,
              color: AppColors.second400,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h, // 📏
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: AppColors.second800,
                  ),
                ),
                if (item.formattedDate.isNotEmpty)
                  Text(
                    item.formattedDate,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.grey200,
                    ),
                  ),
                if (item.text.isNotEmpty)
                  Text(
                    item.text,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.main600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
