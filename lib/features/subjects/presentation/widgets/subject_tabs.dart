import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// تبويبات صفحة المادة: حاوية زرقاء فاتحة وفيها الشريحة المحددة بلون main600.
/// الأول في البداية (يمين في RTL): المحتوى، إختبارات، نشاطات يومية.
/// 📏 حشوة الحاوية 4، ارتفاع الشريحة 44 (الحاوية ≈ 52)، Radius الحاوية 11
/// والشريحة 8، لون الحاوية (second100).
class SubjectTabs extends StatelessWidget {
  const SubjectTabs({
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
    return Container(
      padding: EdgeInsets.all(4.w), // 📏
      decoration: BoxDecoration(
        color: AppColors.second100,
        borderRadius: BorderRadius.circular(11.r), // 📏
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8.r), // 📏
                onTap: () => onChanged(i),
                child: Container(
                  height: 44.h, // 📏
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.main600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r), // 📏
                  ),
                  child: Text(
                    labels[i],
                    style: AppTextStyles.font14Medium.copyWith(
                      color: i == selected ? AppColors.white : AppColors.second600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
