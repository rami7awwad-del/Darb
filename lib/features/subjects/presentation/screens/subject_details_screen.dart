import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/home/presentation/widgets/home_search_field.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/subjects/data/models/subject_details_model.dart';
import 'package:darb/features/subjects/data/models/subject_exam_model.dart';
import 'package:darb/features/subjects/presentation/cubit/subject_details_cubit.dart';
import 'package:darb/features/subjects/presentation/widgets/subject_cards.dart';
import 'package:darb/features/subjects/presentation/widgets/subject_tabs.dart';

/// Screen that shows the subject details.
class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key, required this.subject});

  final SubjectModel subject;

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

/// State for the subject details screen widget.
class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  static const _tabs = ['المحتوى', 'إختبارات', 'نشاطات يومية'];

  final _search = TextEditingController();
  int _tab = 0;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _match(String a, String b) =>
      _query.isEmpty ||
      a.toLowerCase().contains(_query) ||
      b.toLowerCase().contains(_query);

  /// Opens quiz.
  void _openQuiz(SubjectExamModel exam, String prefix) {
    if (exam.questions.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('لا توجد أسئلة حاليًا')));
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: QuizArgs(
        title: '$prefix ${widget.subject.name}',
        questions: exam.questions,
        examId: exam.id,
      ),
    );
  }

  List<Widget> _items(SubjectDetailsModel d) {
    switch (_tab) {
      case 0:
        return [
          for (final c in d.courses)
            if (_match(c.courseName, c.professor))
              SubjectCourseCard(
                course: c,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.courseDetails,
                  arguments: c,
                ),
              ),
        ];
      case 1:
        return [
          for (final e in d.exams)
            if (_match(e.title, e.professor))
              SubjectExamCard(
                exam: e,
                kind: SubjectExamKind.exam,
                onTap: () => _openQuiz(e, 'إختبار'),
              ),
        ];
      default:
        return [
          for (final e in d.dailyActivities)
            if (_match(e.title, e.professor))
              SubjectExamCard(
                exam: e,
                kind: SubjectExamKind.activity,
                onTap: () => _openQuiz(e, 'نشاط'),
              ),
        ];
    }
  }

  String get _emptyText {
    if (_query.isNotEmpty) return 'لا توجد نتائج';
    return switch (_tab) {
      0 => 'لا توجد دورات حاليًا',
      1 => 'لا توجد اختبارات حاليًا',
      _ => 'لا توجد نشاطات حاليًا',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: widget.subject.name,
            icon: null,
            onBack: () => Navigator.pop(context),
            bottom: HomeSearchField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: BlocBuilder<SubjectDetailsCubit, BaseState<SubjectDetailsModel>>(
              builder: (context, state) {
                final cubit = context.read<SubjectDetailsCubit>();
                if (state.stateValue == StateValue.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final items = _items(state.data!);
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                      child: SubjectTabs(
                        labels: _tabs,
                        selected: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.main600,
                        onRefresh: () => cubit.load(silent: true),
                        child: items.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 80.h),
                                  Center(
                                    child: Text(
                                      _emptyText,
                                      style: AppTextStyles.font14Regular.copyWith(
                                        color: AppColors.grey300,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                                itemCount: items.length,
                                separatorBuilder: (_, __) => SizedBox(height: 24.h),
                                itemBuilder: (_, i) => items[i],
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
