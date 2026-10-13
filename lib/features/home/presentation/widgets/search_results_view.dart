import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';

/// نتائج البحث (المواد والاختبارات).
/// ⚠️ لا يوجد تصميم لنتائج البحث في Figma: هذا تصميم مبدئي بسيط، استبدله عند توفره.
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key, required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    switch (data.searchStatus) {
      case SearchStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.main600),
        );
      case SearchStatus.failure:
        return _Message(text: data.searchMessage ?? 'تعذر إتمام البحث');
      case SearchStatus.idle:
      case SearchStatus.ready:
        break;
    }

    final result = data.searchResult;
    if (result.isEmpty) return const _Message(text: 'لا توجد نتائج');

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (result.subjects.isNotEmpty) ...[
          const SectionHeader(title: 'المواد'),
          SizedBox(height: 8.h),
          for (final s in result.subjects)
            _ResultTile(
              leading: ClipOval(
                child: AppNetworkImage(url: s.image, width: 44.w, height: 44.w),
              ),
              title: s.name,
              trailing: s.isFree
                  ? null
                  : Icon(
                      PhosphorIconsRegular.lock,
                      size: 18.w,
                      color: AppColors.grey200,
                    ),
            ),
          SizedBox(height: 16.h),
        ],
        if (result.exams.isNotEmpty) ...[
          const SectionHeader(title: 'الاختبارات'),
          SizedBox(height: 8.h),
          for (final e in result.exams)
            _ResultTile(
              leading: Icon(
                PhosphorIconsRegular.exam,
                size: 28.w,
                color: AppColors.second500,
              ),
              title: e.title,
              subtitle: '${e.professor} · ${e.questionsCount} سؤال',
            ),
        ],
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.grey300,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey300),
        ),
      ),
    );
  }
}
