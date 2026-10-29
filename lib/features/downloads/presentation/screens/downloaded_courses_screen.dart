import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/downloads/data/models/downloaded_item.dart';
import 'package:darb/features/downloads/presentation/widgets/downloaded_item_tile.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';

/// شاشة "الكورسات المحملة".
/// ⚠️ الواجهة جاهزة، لكن لا يوجد نظام تنزيل (ولا endpoint) بعد.
/// TODO: مرّر [items] من مخزن التنزيلات المحلي عند بنائه. وهي فارغة الآن فتظهر رسالة "لا توجد تنزيلات".
class DownloadedCoursesScreen extends StatelessWidget {
  const DownloadedCoursesScreen({super.key, this.items = const []});

  final List<DownloadedItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'الكورسات المحملة',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد كورسات محملة',
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w, // 📏
                      vertical: 24.h, // 📏
                    ),
                    itemCount: items.length,
                    separatorBuilder: (context, _) => SizedBox(height: 24.h), // 📏
                    itemBuilder: (_, i) => DownloadedItemTile(item: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
