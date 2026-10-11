import 'package:darb/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/features/home/data/models/news_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';

/// قسم "اخر الاخبار": بطاقات صور عريضة بقائمة أفقية.
/// TODO: فتح [NewsModel.link] يحتاج حزمة url_launcher (غير مضافة لـ pubspec).
/// ⚠️ قياس تقديري: ارتفاع البطاقة (120) وعرضها (85% من الشاشة) وRadius (16).
class NewsSection extends StatelessWidget {
  const NewsSection({super.key, required this.news, this.onNewsTap});

  final List<NewsModel> news;
  final ValueChanged<NewsModel>? onNewsTap;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();

    final cardWidth = MediaQuery.of(context).size.width * 0.85;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const SectionHeader(title: 'اخر الاخبار'),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: news.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) => InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => onNewsTap?.call(news[i]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AppNetworkImage(
                  url: news[i].image,
                  width: cardWidth,
                  height: 120.h,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
