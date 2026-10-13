import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
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

/// تبويب الرئيسية. يتطلب HomeCubit أعلاه في الشجرة (يُنشأ مع مسار mainLayout).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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
              // TODO: شاشة الإشعارات وشاشة الإنجازات عند إنشائهما.
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.home, required this.onRefresh});

  final HomeDataModel home;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // ⚠️ قياس تقديري: الفراغ بين الأقسام (20)
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
            child: CurriculumProgressCard(
              percent: home.completionRate,
              coursesCount: home.subjectCount,
              // TODO: شاشة تفاصيل التقدم.
            ),
          ),
          gap,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: PromoBanner(onTap: () => showCompleteAccountFlow(context)),
          ),
          gap,
          SubjectsSection(
            subjects: home.subjects,
            // TODO: "أظهر الكل" → قائمة المواد (subjects/all جاهز في HomeRepository).
          ),
          gap,
          NewsSection(
            news: home.news,
            // TODO: فتح الرابط (url_launcher) أو قائمة الأخبار (news/all جاهز).
          ),
          gap,
          CoursesSection(courses: home.courses),
        ],
      ),
    );
  }
}

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
