import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:darb/features/quiz/presentation/widgets/quiz_question_card.dart';

/// شاشة الاختبار (Quizze Pages 1): كل الأسئلة في قائمة واحدة وزر "النتيجة" ثابت أسفلها.
/// الأسئلة والأجوبة تأتي جاهزة من subjects/details (لا طلب إضافي).
/// يتطلب QuizCubit في الشجرة.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.args});

  final QuizArgs args;

  Future<void> _finish(BuildContext context, Map<int, int> selected) async {
    final unanswered = args.questions.length - selected.length;
    if (unanswered > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('إنهاء الاختبار؟'),
          content: Text('لم تجب عن $unanswered سؤال، وسيُحسب خاطئًا.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('متابعة الحل'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('إنهاء'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
    }

    // TODO: إرسال المحاولة إلى exams/attend-exam عند معرفة شكل الطلب.
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizResult,
      arguments: QuizOutcome(
        title: args.title,
        questions: args.questions,
        selected: selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: args.title,
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<QuizCubit, Map<int, int>>(
              builder: (context, selected) => ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h), // 📏
                itemCount: args.questions.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h), // 📏
                itemBuilder: (_, i) {
                  final q = args.questions[i];
                  return QuizQuestionCard(
                    number: i + 1,
                    question: q,
                    selectedId: selected[q.id],
                    onSelect: (a) => cubit.select(q.id, a.id),
                  );
                },
              ),
            ),
          ),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h), // 📏
            child: SafeArea(
              top: false,
              child: BlocBuilder<QuizCubit, Map<int, int>>(
                builder: (context, selected) => AppPrimaryButton(
                  text: 'النتيجة',
                  onPressed: () => _finish(context, selected),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
