import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_image_viewer.dart';

/// صور ألبوم واحد في شبكة من عمودين. الصور تأتي مع الألبوم من galleries/paginate،
/// فلا حاجة لـ Cubit. الضغط على صورة يفتحها في نافذة كبيرة.
/// ⚠️ قياس تقديري: نسبة الصورة (1.31 من Figma)، المسافات (12)، نصف القطر (12).
class GalleryAlbumScreen extends StatelessWidget {
  const GalleryAlbumScreen({super.key, required this.album});

  final GalleryModel album;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(onBack: () => Navigator.pop(context)),
          Expanded(
            child: album.images.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد صور في هذا الألبوم',
                      style: AppTextStyles.font14Regular
                          .copyWith(color: AppColors.grey300),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: album.images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.31,
                    ),
                    itemBuilder: (context, i) {
                      final url = album.images[i];
                      return GestureDetector(
                        onTap: () => showGalleryImageViewer(context, url),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: AppShadows.midLight,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: AppNetworkImage(
                              url: url,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
