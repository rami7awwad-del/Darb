import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';
import 'package:darb/features/subscription/presentation/cubit/my_subscriptions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Screen that shows the my subscriptions.
class MySubscriptionsScreen extends StatelessWidget {
  const MySubscriptionsScreen({super.key});

  Future<void> _subscribe(BuildContext context) async {
    final cubit = context.read<MySubscriptionsCubit>();
    final done =
        await Navigator.pushNamed<bool>(context, AppRoutes.subscription);
    if (done == true) cubit.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MySubscriptionsCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          GalleryHeader(
            title: 'اشتراكاتي',
            icon: null,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child:
                BlocBuilder<MySubscriptionsCubit, BaseState<List<CourseModel>>>(
              builder: (context, state) {
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final items = state.data;
                if (items == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main600),
                  );
                }
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
                                'لا توجد اشتراكات حاليًا',
                                style: AppTextStyles.font14Regular
                                    .copyWith(color: AppColors.grey300),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 24.h,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => SizedBox(height: 24.h),
                          itemBuilder: (_, i) =>
                              _SubscriptionTile(index: i + 1, course: items[i]),
                        ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: AppPrimaryButton(
                text: 'اشتراك جديد',
                onPressed: () => _subscribe(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile widget for the subscription.
class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.index, required this.course});

  final int index;
  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.courseDetails,
        arguments: course,
      ),
      child: Row(
        children: [
          Container(
            width: 75.w,
            height: 60.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.second400,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Text(
              '$index',
              style: AppTextStyles.font20Medium.copyWith(color: AppColors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font14Regular
                      .copyWith(color: AppColors.main600),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.w,
                  children: [
                    Icon(
                      ProfileIcons.videoMeta,
                      size: 16.w,
                      color: AppColors.second500,
                    ),
                    Text(
                      '${course.semestersCount} فصول ، ${course.lessonsCount} درس',
                      style: AppTextStyles.font12Regular
                          .copyWith(color: AppColors.grey300),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColors.second500,
              shape: BoxShape.circle,
            ),
            child: Icon(ProfileIcons.play, size: 22.w, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
