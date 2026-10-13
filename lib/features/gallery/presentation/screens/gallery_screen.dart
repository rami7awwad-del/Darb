import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_album_card.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';

/// تبويب المعرض (قائمة الألبومات). يتطلب GalleryCubit أعلاه في الشجرة
/// (يُنشأ مع مسار mainLayout).
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TODO: شاشة الإشعارات عند إنشائها (onNotifications).
        const GalleryHeader(),
        Expanded(
          child: BlocBuilder<GalleryCubit, BaseState<GalleryData>>(
            builder: (context, state) {
              final cubit = context.read<GalleryCubit>();

              if (state.stateValue == StateValue.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.main600),
                );
              }
              if (state.stateValue == StateValue.error) {
                return _LoadError(
                  message: state.errorMessage,
                  onRetry: cubit.load,
                );
              }
              return _AlbumsGrid(state: state.data!);
            },
          ),
        ),
      ],
    );
  }
}

class _AlbumsGrid extends StatelessWidget {
  const _AlbumsGrid({required this.state});

  final GalleryData state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GalleryCubit>();

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // قرب نهاية القائمة: حمّل الصفحة التالية.
        if (n.metrics.extentAfter < 300) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.main600,
        onRefresh: () => cubit.load(silent: true),
        child: state.albums.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Text(
                      'لا توجد ألبومات حاليًا',
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    sliver: SliverGrid.builder(
                      itemCount: state.albums.length,
                      // ⚠️ قياس تقديري: ارتفاع البطاقة (195 من Figma) والمسافات (12).
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        mainAxisExtent: 195.h,
                      ),
                      itemBuilder: (context, i) {
                        final album = state.albums[i];
                        return GalleryAlbumCard(
                          album: album,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.galleryAlbum,
                            arguments: album,
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.loadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.main600,
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
