import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// تبويبات شريحية: المواد / الفصول / الباقات (الأول في البداية = يمين في RTL).
/// ⚠️ قياس تقديري: ارتفاع الشريحة (40) والمسافة بينها (12) ولون المحدد (main500).
class LibraryTabs extends StatelessWidget {
  const LibraryTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: _Chip(
              label: labels[i],
              selected: i == selected,
              onTap: () => onChanged(i),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.r);
    return Material(
      color: selected ? AppColors.main500 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppColors.main500 : const Color(0xFFDBDBDB),
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          height: 40.h,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.font14Medium.copyWith(
                color: selected ? AppColors.white : AppColors.grey400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
