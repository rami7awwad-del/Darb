import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/achievements/presentation/cubit/achievements_cubit.dart';
import 'package:darb/features/achievements/presentation/widgets/achievement_subject_card.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/profile/presentation/widgets/profile_summary_card.dart';

/// Screen that shows the achievements.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'إنجازاتي',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<AchievementsCubit, BaseState<AchievementsData>>(
              builder: (context, state) {
                final cubit = context.read<AchievementsCubit>();
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
                return _Body(data: state.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Small private widget used only in this file.
class _Body extends StatelessWidget {
  const _Body({required this.data});

  final AchievementsData data;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AchievementsCubit>();

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.main600,
        onRefresh: () => cubit.load(silent: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              sliver: SliverToBoxAdapter(
                child: ProfileSummaryCard(profile: data.profile!, topGap: 0),
              ),
            ),
            if (data.coursesLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  ),
                ),
              )
            else if (data.coursesError != null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200.h,
                  child: AppLoadError(
                    message: data.coursesError,
                    onRetry: cubit.loadCourses,
                  ),
                ),
              )
            else if (data.courses.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 32.h),
                  child: Center(
                    child: Text(
                      'لا توجد مواد بعد',
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList.separated(
                  itemCount: data.courses.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, i) =>
                      AchievementSubjectCard(course: data.courses[i]),
                ),
              ),
            SliverToBoxAdapter(
              child: data.loadingMore
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.main600),
                      ),
                    )
                  : SizedBox(height: 24.h),
            ),
          ],
        ),
      ),
    );
  }
}
