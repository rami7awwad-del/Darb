import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';

/// بطاقة سؤال: رقم السؤال ونصه، ثم الاختيارات (اختيار واحد).
/// 📏 Radius 16، حشوة 16، Radius الاختيار 11، المسافة بين الاختيارات 12.
class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.number,
    required this.question,
    required this.selectedId,
    required this.onSelect,
  });

  final int number;
  final QuizQuestion question;
  final int? selectedId;
  final ValueChanged<QuizAnswer> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w), // 📏
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r), // 📏
        border: Border.all(color: AppColors.main100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h, // 📏
        children: [
          Row(
            spacing: 12.w, // 📏
            children: [
              QuizNumberBadge(number: number),
              Expanded(
                child: Text(
                  question.title,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ),
            ],
          ),
          for (final a in question.answers)
            _Option(
              answer: a,
              selected: a.id == selectedId,
              onTap: () => onSelect(a),
            ),
        ],
      ),
    );
  }
}

class QuizNumberBadge extends StatelessWidget {
  const QuizNumberBadge({
    super.key,
    required this.number,
    this.background = AppColors.main50,
    this.color = AppColors.main600,
  });

  final int number;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w, // 📏
      height: 32.w, // 📏
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: AppTextStyles.font14Medium.copyWith(color: color),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  final QuizAnswer answer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r); // 📏
    return Material(
      color: selected ? AppColors.main50 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppColors.main600 : AppColors.grey100,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 48.h), // 📏
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // 📏
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer.title,
                  textAlign: TextAlign.center,
                  style: (selected
                          ? AppTextStyles.font14Medium
                          : AppTextStyles.font14Regular)
                      .copyWith(
                    color: selected ? AppColors.main600 : AppColors.grey500,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.radio_button_checked,
                  size: 20.w, // 📏
                  color: AppColors.main600,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
