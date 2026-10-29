import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/downloads/data/models/downloaded_item.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';

/// صف عنصر محمّل: مربع أزرق برقم في البداية، العنوان مع النوع والمدة، وزر تشغيل/قراءة في النهاية.
/// 📏 مربع الرقم 75×60 (من Figma بعد التحويل لمقياس 430)، Radius 11، حجم رقم 20،
/// حجم العنوان 14 والتفاصيل 12، دائرة التشغيل 36، المسافات 12.
class DownloadedItemTile extends StatelessWidget {
  const DownloadedItemTile({super.key, required this.item, this.onTap});

  final DownloadedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.kind == DownloadedKind.video;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 75.w, // 📏
            height: 60.h, // 📏
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.second400,
              borderRadius: BorderRadius.circular(11.r), // 📏
            ),
            child: Text(
              '${item.order}',
              style: AppTextStyles.font20Medium.copyWith(
                color: AppColors.white, // 📏 حجم الرقم 20
              ),
            ),
          ),
          SizedBox(width: 12.w), // 📏
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.main600, // 📏 حجم الخط 14
                  ),
                ),
                SizedBox(height: 4.h), // 📏
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.w, // 📏
                  children: [
                    Icon(
                      isVideo ? ProfileIcons.videoMeta : ProfileIcons.pdfMeta,
                      size: 16.w, // 📏
                      color: AppColors.second500,
                    ),
                    Text(
                      item.meta,
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w), // 📏
          if (isVideo)
            Container(
              width: 36.w, // 📏
              height: 36.w, // 📏
              decoration: const BoxDecoration(
                color: AppColors.second500,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ProfileIcons.play,
                size: 22.w, // 📏
                color: AppColors.white,
              ),
            )
          else
            SizedBox(
              width: 36.w, // 📏
              height: 36.w, // 📏
              child: Icon(
                ProfileIcons.book,
                size: 28.w, // 📏
                color: AppColors.second500,
              ),
            ),
        ],
      ),
    );
  }
}
