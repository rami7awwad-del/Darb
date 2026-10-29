import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:darb/features/notifications/presentation/widgets/notification_tile.dart';

/// شاشة الإشعارات. تتطلب NotificationsCubit في الشجرة (يُنشأ في app_routes).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GalleryHeader(
            title: 'الإشعارات',
            icon: null,
            onBack: () => Navigator.pop(context),
            trailing: const _UnreadBadge(),
          ),
          const Expanded(child: _Body()),
        ],
      ),
    );
  }
}

/// دائرة بيضاء بعدد غير المقروء (المحمَّل حاليًا). تختفي عند الصفر.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, BaseState<NotificationsData>>(
      builder: (context, state) {
        final count = state.data?.unreadCount ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: AppTextStyles.font14Medium.copyWith(
              color: AppColors.main600,
            ),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    return BlocBuilder<NotificationsCubit, BaseState<NotificationsData>>(
      builder: (context, state) {
        if (state.stateValue == StateValue.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.main600),
          );
        }
        if (state.stateValue == StateValue.error) {
          return AppLoadError(message: state.errorMessage, onRetry: cubit.load);
        }

        final data = state.data!;
        if (data.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.main600,
            onRefresh: () => cubit.load(silent: true),
            child: ListView(
              children: [
                SizedBox(height: 160.h), // 📏
                Center(
                  child: Text(
                    'لا توجد إشعارات',
                    style: AppTextStyles.font14Regular.copyWith(
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.main600,
          onRefresh: () => cubit.load(silent: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 200) cubit.loadMore();
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.items.length + (data.loadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  Container(height: 4.h, color: AppColors.grey50), // 📏
              itemBuilder: (context, i) {
                if (i >= data.items.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.main600,
                      ),
                    ),
                  );
                }
                return NotificationTile(item: data.items[i]);
              },
            ),
          ),
        );
      },
    );
  }
}
