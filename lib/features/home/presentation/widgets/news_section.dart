import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/core/widgets/app_responsive.dart';
import 'package:darb/features/home/data/models/news_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section widget for the news.
class NewsSection extends StatelessWidget {
  const NewsSection({super.key, required this.news, this.onNewsTap});

  // Width to height ratio of a news image.
  static const double _aspectRatio = 2.4;

  final List<NewsModel> news;
  final ValueChanged<NewsModel>? onNewsTap;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const SectionHeader(title: 'اخر الاخبار'),
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth;
            // Narrower cards in landscape so more of them fit on screen.
            final factor = isLandscapeOf(context) ? 0.46 : 0.85;
            final cardWidth = (available * factor).clamp(240.0, 560.0);
            // Height follows the width so every news image keeps the same shape.
            final cardHeight = cardWidth / _aspectRatio;

            return SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: news.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (context, i) => SizedBox(
                  width: cardWidth,
                  child: _NewsCard(
                    item: news[i],
                    aspectRatio: _aspectRatio,
                    onTap: () => onNewsTap?.call(news[i]),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Card widget for the news.
class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.item,
    required this.aspectRatio,
    required this.onTap,
  });

  final NewsModel item;
  final double aspectRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ResponsiveImageCard(
      aspectRatio: aspectRatio,
      radius: 16.r,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.grey50),
          AppNetworkImage(
            url: item.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        ],
      ),
    );
  }
}
