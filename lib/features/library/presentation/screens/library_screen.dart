import 'package:darb/features/subscription/presentation/subscription_access.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/presentation/widgets/home_search_field.dart';
import 'package:darb/features/library/presentation/cubit/library_cubit.dart';
import 'package:darb/features/library/presentation/widgets/library_course_card.dart';
import 'package:darb/features/library/presentation/widgets/library_package_card.dart';
import 'package:darb/features/library/presentation/widgets/library_semester_card.dart';
import 'package:darb/features/library/presentation/widgets/library_tabs.dart';

/// Screen that shows the library.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

/// State for the library screen widget.
class _LibraryScreenState extends State<LibraryScreen> {
  static const _tabs = ['المواد', 'الفصول', 'الباقات'];

  final _search = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Handles tab.
  void _onTab(int i) {
    setState(() => _tab = i);
    final cubit = context.read<LibraryCubit>();
    if (i == 1) cubit.loadSemesters();
    if (i == 2) cubit.loadPackages();
  }

  void _continuePackage(BuildContext context, LibraryPackage package) {
    final subjects = package.subjects;
    if (subjects.isEmpty) {
      showAppSnackBar(context, 'لا توجد مواد في هذه الباقة');
      return;
    }
    bool open(CourseModel c) => c.isFree || c.isSubscription;
    final target = subjects.where((c) => open(c) && c.lessonRate < 100).firstOrNull ??
        subjects.where(open).firstOrNull ??
        subjects.first;
    openCourseWithAccess(context, target);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();

    return Column(
      children: [
        const GalleryHeader(title: 'موادي', icon: Icons.library_books_rounded),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Column(
            spacing: 16.h,
            children: [
              HomeSearchField(controller: _search, onChanged: cubit.search),
              LibraryTabs(labels: _tabs, selected: _tab, onChanged: _onTab),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: BlocBuilder<LibraryCubit, BaseState<LibraryData>>(
            builder: (context, state) => switch (_tab) {
              0 => _CoursesTab(state: state),
              1 => _StateList(
                state: state.data!.semesters,
                itemsCount: state.data!.visibleSemesters.length,
                emptyText: state.data!.query.isEmpty
                    ? 'لا توجد فصول حاليًا'
                    : 'لا نتائج مطابقة للبحث',
                onRefresh: () => cubit.loadSemesters(force: true),
                itemBuilder: (i) => LibrarySemesterCard(
                  semester: state.data!.visibleSemesters[i],
                  onContinue: () => openCourseWithAccess(
                    context,
                    state.data!.visibleSemesters[i].course,
                  ),
                ),
              ),
              _ => _StateList(
                state: state.data!.packages,
                itemsCount: state.data!.visiblePackages.length,
                emptyText: state.data!.query.isEmpty
                    ? 'لا توجد باقات حاليًا'
                    : 'لا نتائج مطابقة للبحث',
                onRefresh: () => cubit.loadPackages(force: true),
                itemBuilder: (i) => LibraryPackageCard(
                  package: state.data!.visiblePackages[i],
                  onDetails: () {},
                  onContinue: () => _continuePackage(
                    context,
                    state.data!.visiblePackages[i],
                  ),
                ),
              ),
            },
          ),
        ),
      ],
    );
  }
}

/// Widget that shows the courses tab.
class _CoursesTab extends StatelessWidget {
  const _CoursesTab({required this.state});

  final BaseState<LibraryData> state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();

    if (state.stateValue == StateValue.loading) {
      return const _Spinner();
    }
    if (state.stateValue == StateValue.error) {
      return _LoadError(message: state.errorMessage, onRetry: cubit.load);
    }

    final data = state.data!;
    final courses = data.visibleCourses;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.main600,
        onRefresh: () => cubit.load(silent: true),
        child: courses.isEmpty
            ? _EmptyList(
                text: data.query.isEmpty
                    ? 'لا توجد مواد حاليًا'
                    : 'لا نتائج مطابقة للبحث',
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                itemCount: courses.length + (data.loadingMore ? 1 : 0),
                separatorBuilder: (_, _) => SizedBox(height: 16.h),
                itemBuilder: (context, i) {
                  if (i >= courses.length) return const _Spinner();
                  return LibraryCourseCard(
                    course: courses[i],
                    onContinue: () =>
                        openCourseWithAccess(context, courses[i]),
                  );
                },
              ),
      ),
    );
  }
}

/// List widget for the state.
class _StateList extends StatelessWidget {
  const _StateList({
    required this.state,
    required this.itemsCount,
    required this.emptyText,
    required this.onRefresh,
    required this.itemBuilder,
  });

  final LoadState<dynamic> state;
  final int itemsCount;
  final String emptyText;
  final Future<void> Function() onRefresh;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (state.items == null) {
      if (state.error != null) {
        return _LoadError(message: state.error, onRetry: onRefresh);
      }
      return const _Spinner();
    }

    return RefreshIndicator(
      color: AppColors.main600,
      onRefresh: onRefresh,
      child: itemsCount == 0
          ? _EmptyList(text: emptyText)
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              itemCount: itemsCount,
              separatorBuilder: (_, _) => SizedBox(height: 16.h),
              itemBuilder: (_, i) => itemBuilder(i),
            ),
    );
  }
}

/// Small private widget used only in this file.
class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.main600),
  );
}

/// List widget for the empty.
class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        Center(
          child: Text(
            text,
            style: AppTextStyles.font14Regular.copyWith(
              color: AppColors.grey300,
            ),
          ),
        ),
      ],
    );
  }
}

/// Error message with a retry button.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.h,
          children: [
            Text(
              message ?? 'تعذر تحميل البيانات',
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Regular.copyWith(
                color: AppColors.grey400,
              ),
            ),
            AppOutlineButton(text: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
