import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/presentation/widgets/home_search_field.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:darb/features/quiz/presentation/cubit/tests_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Screen that shows the tests.
class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

/// State for the tests screen widget.
class _TestsScreenState extends State<TestsScreen> {
  int _tab = 0;
  bool _opening = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the list by title or professor name.
  List<QuizListItem> _filter(List<QuizListItem> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.professor.toLowerCase().contains(q),
        )
        .toList();
  }

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
            // Search bar sits inside the teal header, as in the design.
            bottom: HomeSearchField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: _TabsBar(
              labels: const ['إختبارات', 'نشاطات يومية'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
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
                final all = _tab == 0 ? data.exams : data.activities;
                final items = _filter(all);
                return RefreshIndicator(
                  color: AppColors.main600,
                  onRefresh: () => cubit.load(silent: true),
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 120.h),
                            Center(
                              child: Text(
                                all.isNotEmpty
                                    ? 'لا توجد نتائج'
                                    : _tab == 0
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
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
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

/// Full-width segmented tabs (grey track, teal selected segment).
class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  static const Color _track = Color(0xFFAFB6BC);

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        color: _track,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Material(
                  color: i == selected ? const Color(0xFF34BBBD) : Colors.transparent,
                  borderRadius: radius,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: () => onChanged(i),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: AppTextStyles.font14Medium.copyWith(
                            color: i == selected
                                ? AppColors.white
                                : AppColors.grey400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for the test: illustration on the start side, then title,
/// professor + points, and the questions count.
class _TestCard extends StatelessWidget {
  const _TestCard({required this.item, required this.onTap});

  // Fixed points value shown on every card (not coming from the API).
  static const int _points = 22;

  final QuizListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);
    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0xFF7CA4F2)),
          ),
          child: Row(
            spacing: 12.w,
            children: [
              // Replace with Image.asset(...) once the Figma illustrations
              // are added to assets/images.
              Icon(
                item.isActivity ? Icons.psychology_rounded : Icons.quiz_rounded,
                size: 52.w,
                color: AppColors.second400,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.h,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font16Medium.copyWith(
                        color: AppColors.main600,
                      ),
                    ),
                    Row(
                      spacing: 24.w,
                      children: [
                        if (item.professor.isNotEmpty)
                          Flexible(
                            child: Text(
                              item.professor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font12Regular.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4.w,
                            children: [
                              Icon(
                                Icons.toll_outlined,
                                size: 14.w,
                                color: AppColors.grey200,
                              ),
                              Text(
                                '$_points',
                                style: AppTextStyles.font14Regular.copyWith(
                                  color: AppColors.second500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (item.questionsCount > 0)
                      Text(
                        '${item.questionsCount} سؤال',
                        style: AppTextStyles.font14Medium.copyWith(
                          color: AppColors.main600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
