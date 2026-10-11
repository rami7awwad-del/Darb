import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';

/// بطاقة ألبوم: صورة الغلاف واسم الألبوم وعدد صوره.
/// ⚠️ قياس تقديري: نصف قطر البطاقة (16) والصورة (12)، الحشوة (8)،
/// لون الحد (second100)، والمسافة بين الصورة والنص (8).
/// ⚠️ النص "ألبوم {الاسم} ({العدد})" افتراض من Figma؛ إن كان الاسم القادم من
/// الـ API يحمل كلمة "ألبوم" أصلًا فاحذفها من هنا.
class GalleryAlbumCard extends StatelessWidget {
  const GalleryAlbumCard({super.key, required this.album, required this.onTap});

  final GalleryModel album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.second100, width: 1),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: AppNetworkImage(
                    url: album.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ألبوم ${album.name} (${album.count})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.font12Medium
                    .copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
