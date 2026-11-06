import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:darb/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:darb/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';
import 'package:darb/features/profile/presentation/widgets/profile_menu.dart';
import 'package:darb/features/profile/presentation/widgets/profile_summary_card.dart';
import 'package:darb/features/support/data/models/info_page_type.dart';
import 'package:darb/features/support/presentation/widgets/about_sheet.dart';
import 'package:darb/features/support/presentation/widgets/contact_sheet.dart';

/// تبويب الملف الشخصي. يتطلب ProfileCubit أعلاه في الشجرة (يُنشأ مع مسار mainLayout).
/// 📏 هوامش القائمة ومسافات الأقسام من لقطة Figma (16 جانبيًا، 24 بين البطاقة والقائمة).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, String route, {Object? arguments}) =>
      Navigator.pushNamed(context, route, arguments: arguments);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GalleryHeader(
          title: 'الملف الشخصي',
          icon: ProfileIcons.profileHeader,
        ),
        Expanded(
          child: BlocBuilder<ProfileCubit, BaseState<ProfileModel>>(
            builder: (context, state) {
              final cubit = context.read<ProfileCubit>();
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
              final profile = state.data!;

              return RefreshIndicator(
                color: AppColors.main600,
                onRefresh: () => cubit.load(silent: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 24.h), // 📏
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w), // 📏
                      child: ProfileSummaryCard(profile: profile),
                    ),
                    SizedBox(height: 8.h), // 📏
                    const ProfileMenuTitle('الدعم والمعلومات'),
                    ProfileMenuTile(
                      icon: ProfileIcons.faq,
                      label: 'الأسئلة الشائعة',
                      onTap: () => _open(context, AppRoutes.faqs),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.contact,
                      label: 'تواصل معنا',
                      onTap: () => showContactSheet(context, profile: profile),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.subscription,
                      label: 'الاشتراك',
                      onTap: () => _open(context, AppRoutes.mySubscriptions),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.achievements,
                      label: 'إنجازاتي',
                      onTap: () => _open(context, AppRoutes.achievements),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.about,
                      label: 'حول التطبيق',
                      onTap: () => showAboutSheet(context),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.privacy,
                      label: 'سياسة الخصوصية',
                      onTap: () => _open(
                        context,
                        AppRoutes.infoPage,
                        arguments: InfoPageType.privacy,
                      ),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.downloads,
                      label: 'الكورسات المحملة',
                      onTap: () => _open(context, AppRoutes.downloadedCourses),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.terms,
                      label: 'سياسة الاستخدام',
                      onTap: () => _open(
                        context,
                        AppRoutes.infoPage,
                        arguments: InfoPageType.terms,
                      ),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.exams,
                      label: 'إختباراتي',
                      onTap: () => _open(context, AppRoutes.tests),
                    ),
                    SizedBox(height: 8.h), // 📏
                    const Divider(height: 1, color: AppColors.grey50),
                    const ProfileMenuTitle('الإعدادات'),
                    ProfileMenuTile(
                      icon: ProfileIcons.editProfile,
                      label: 'تعديل الملف الشخصي',
                      onTap: () => showEditProfileSheet(
                        context,
                        profile: profile,
                        onUpdated: cubit.replace,
                      ),
                    ),
                    ProfileMenuTile(
                      icon: ProfileIcons.logout,
                      label: 'تسجيل الخروج',
                      onTap: () => showLogoutDialog(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
