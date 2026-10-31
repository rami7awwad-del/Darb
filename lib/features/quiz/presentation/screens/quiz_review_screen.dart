import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/presentation/widgets/quiz_question_card.dart';

/// مراجعة تفصيلية (Quizze Pages 3): لكل سؤال إجابتك، وإن كانت خاطئة الإجابة الصحيحة.
class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.outcome});

  final QuizOutcome outcome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'نتائج الإختبار',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h), // 📏
              itemCount: outcome.questions.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 16.h), // 📏
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Text(
                    'مراجعة تفصيلية',
                    style: AppTextStyles.font14Medium.copyWith(
                      color: AppColors.grey500,
                    ),
                  );
                }
                final q = outcome.questions[i - 1];
                return _ReviewCard(
                  number: i,
                  question: q,
                  chosen: outcome.selectedAnswer(q),
                );
              },
            ),
          ),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h), // 📏
            child: SafeArea(
              top: false,
              child: AppPrimaryButton(
                text: 'الرجوع للصفحة الرئيسية',
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName(AppRoutes.mainLayout),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.question,
    required this.chosen,
  });

  final int number;
  final QuizQuestion question;
  final QuizAnswer? chosen;

  @override
  Widget build(BuildContext context) {
    final isCorrect = chosen?.correct ?? false;
    final accent = isCorrect ? AppColors.main600 : AppColors.danger;
    final correct = question.correctAnswer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r), // 📏
      child: Container(
        color: AppColors.white,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: accent), // 📏
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w), // 📏
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.h, // 📏
                    children: [
                      Row(
                        spacing: 12.w, // 📏
                        children: [
                          QuizNumberBadge(
                            number: number,
                            background: isCorrect
                                ? AppColors.main50
                                : AppColors.dangerLight,
                            color: accent,
                          ),
                          Expanded(
                            child: Text(
                              question.title,
                              style: AppTextStyles.font14Medium.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 20.w, // 📏
                            color: accent,
                          ),
                        ],
                      ),
                      if (isCorrect)
                        _AnswerBox(
                          label: 'إجابتك (صحيحة):',
                          text: chosen!.title,
                          color: AppColors.main600,
                          background: AppColors.main50,
                        )
                      else ...[
                        _AnswerBox(
                          label: chosen == null
                              ? 'لم تجب عن هذا السؤال'
                              : 'إجابتك (خاطئة):',
                          text: chosen?.title ?? '',
                          color: AppColors.danger,
                          background: AppColors.white,
                          borderColor: AppColors.danger,
                          strike: chosen != null,
                        ),
                        if (correct != null)
                          _AnswerBox(
                            label: 'الإجابة الصحيحة:',
                            text: correct.title,
                            color: AppColors.main600,
                            background: AppColors.main50,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({
    required this.label,
    required this.text,
    required this.color,
    required this.background,
    this.borderColor,
    this.strike = false,
  });

  final String label;
  final String text;
  final Color color;
  final Color background;
  final Color? borderColor;
  final bool strike;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w), // 📏
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11.r), // 📏
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.h, // 📏
        children: [
          Text(
            label,
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey400,
            ),
          ),
          if (text.isNotEmpty)
            Text(
              text,
              style: AppTextStyles.font14Bold.copyWith(
                color: color,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
        ],
      ),
    );
  }
}
