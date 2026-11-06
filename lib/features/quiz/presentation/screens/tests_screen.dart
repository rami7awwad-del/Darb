import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:darb/features/quiz/presentation/cubit/tests_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "إختباراتي": تبويب للاختبارات (exams/my) وآخر للنشاطات (daily-activities/my).
/// الضغط على عنصر يجلب exams/result: إن كان محلولًا سابقًا تُفتح النتيجة، وإلا الحل.
/// يتطلب TestsCubit في الشجرة.
class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  int _tab = 0;
  bool _opening = false;

  Future<void> _open(QuizListItem item) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final details = await context.read<QuizRepository>().getExam(item.id);
      if (!mounted) return;
      if (details.attended) {
        await Navigator.pushNamed(
          context,
          AppRoutes.quizResult,
          arguments: QuizOutcome.fromDetails(details, title: item.title),
        );
      } else if (details.questions.isEmpty) {
        showAppSnackBar(context, 'لا توجد أسئلة حاليًا');
      } else {
        await Navigator.pushNamed(
          context,
          AppRoutes.quiz,
          arguments: QuizArgs(
            title: item.title,
            questions: details.questions,
            examId: item.id,
          ),
        );
      }
      if (mounted) context.read<TestsCubit>().load(silent: true);
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'تعذر فتح الاختبار');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TestsCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          GalleryHeader(
            title: 'إختباراتي',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h), // 📏
            child: Row(
              spacing: 8.w, // 📏
              children: [
                _TabChip(
                  label: 'الاختبارات',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _TabChip(
                  label: 'النشاطات',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TestsCubit, BaseState<TestsData>>(
              builder: (context, state) {
                if (state.stateValue == StateValue.error &&
                    state.data == null) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final data = state.data;
                if (data == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                final items = _tab == 0 ? data.exams : data.activities;
                return RefreshIndicator(
                  color: AppColors.main600,
                  onRefresh: () => cubit.load(silent: true),
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 120.h), // 📏
                            Center(
                              child: Text(
                                _tab == 0
                                    ? 'لا توجد اختبارات بعد'
                                    : 'لا توجد نشاطات بعد',
                                style: AppTextStyles.font14Regular.copyWith(
                                  color: AppColors.grey300,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h), // 📏
                          itemCount: items.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h), // 📏
                          itemBuilder: (_, i) => _TestCard(
                            item: items[i],
                            onTap: () => _open(items[i]),
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

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.main600 : AppColors.main50,
      borderRadius: BorderRadius.circular(20.r), // 📏
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r), // 📏
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h), // 📏
          child: Text(
            label,
            style: AppTextStyles.font14Medium.copyWith(
              color: selected ? AppColors.white : AppColors.main700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.item, required this.onTap});

  final QuizListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r); // 📏
    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w), // 📏
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.grey50),
          ),
          child: Row(
            spacing: 12.w, // 📏
            children: [
              Container(
                width: 44.w, // 📏
                height: 44.w, // 📏
                decoration: const BoxDecoration(
                  color: AppColors.main50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isActivity
                      ? Icons.bolt_rounded
                      : Icons.quiz_outlined,
                  color: AppColors.main600,
                  size: 22.w, // 📏
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.h, // 📏
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font14Medium.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    Text(
                      [
                        if (item.professor.isNotEmpty) item.professor,
                        if (item.questionsCount > 0)
                          '${item.questionsCount} سؤال',
                      ].join(' · '),
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.grey200,
                size: 22.w, // 📏
              ),
            ],
          ),
        ),
      ),
    );
  }
}
