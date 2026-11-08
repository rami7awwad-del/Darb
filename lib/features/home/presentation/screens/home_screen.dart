import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_responsive.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:darb/features/subscription/presentation/subscription_access.dart';
import 'package:flutter/material.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/presentation/widgets/complete_account_flow.dart';
import 'package:darb/features/home/presentation/widgets/courses_section.dart';
import 'package:darb/features/home/presentation/widgets/curriculum_progress_card.dart';
import 'package:darb/features/home/presentation/widgets/home_header.dart';
import 'package:darb/features/home/presentation/widgets/home_search_field.dart';
import 'package:darb/features/home/presentation/widgets/news_section.dart';
import 'package:darb/features/home/presentation/widgets/promo_banner.dart';
import 'package:darb/features/home/presentation/widgets/search_results_view.dart';
import 'package:darb/features/home/presentation/widgets/subjects_section.dart';

/// Screen that shows the home.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for the home screen widget.
class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return BlocBuilder<HomeCubit, BaseState<HomeData>>(
      builder: (context, state) {
        if (state.stateValue == StateValue.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.main600),
          );
        }

        final data = state.data!;
        if (state.stateValue == StateValue.error ||
            data.profile == null ||
            data.home == null) {
          return _LoadError(message: state.errorMessage, onRetry: cubit.load);
        }

        final home = data.home!;

        return Column(
          children: [
            HomeHeader(
              profile: data.profile!,
              unreadCount: home.notificationUnread,
              onNotifications: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              // Medal icon opens the achievements page.
              onAchievements: () =>
                  Navigator.pushNamed(context, AppRoutes.achievements),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: HomeSearchField(
                controller: _searchController,
                onChanged: cubit.onSearchChanged,
              ),
            ),
            Expanded(
              child: data.isSearching
                  ? SearchResultsView(data: data)
                  : _HomeContent(
                      home: home,
                      onRefresh: () => cubit.load(silent: true),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Main content of the home.
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.home, required this.onRefresh});

  final HomeDataModel home;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 20.h);

    return RefreshIndicator(
      color: AppColors.main600,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppContentWidth(
              // Keep the cards readable on wide screens.
              maxWidth: 720,
              child: CurriculumProgressCard(
                percent: home.completionRate,
                coursesCount: home.subjectCount,
                // "التفاصيل" inside the card opens the achievements page.
                onDetails: () =>
                    Navigator.pushNamed(context, AppRoutes.achievements),
              ),
            ),
          ),
          gap,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppContentWidth(
              maxWidth: 720,
              child: PromoBanner(onTap: () => showCompleteAccountFlow(context)),
            ),
          ),
          gap,
          SubjectsSection(
            subjects: home.subjects,
            onShowAll: () => Navigator.pushNamed(context, AppRoutes.subjects),
            onSubjectTap: (subject) => openSubjectWithAccess(context, subject),
          ),
          gap,
          NewsSection(
            news: home.news,
          ),
          gap,
          CoursesSection(
            courses: home.courses,
            // Subscribed/free -> course details, otherwise -> subscription page.
            // Refresh silently after subscribing so the flags are up to date.
            onCourseTap: (course) => openCourseOrSubscription(
              context,
              course,
              onSubscribed: onRefresh,
            ),
          ),
        ],
      ),
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
