import 'package:darb/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';

/// الشريط التركوازي العلوي: الصورة، الترحيب، النقاط والميداليات والدورات،
/// وزرّا الإشعارات والإنجازات.
/// ⚠️ قياس تقديري: ارتفاع الشريط (من الحشوات)، حجم الصورة (48)، حجم الزرين (36)،
/// نصف قطر الحواف (32)، اللون (main600).
/// ⚠️ الدورات = package_count (افتراض)، والميداليات مضافة حسب الملاحظة وليست في Figma.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.profile,
    required this.unreadCount,
    this.onNotifications,
    this.onAchievements,
  });

  final ProfileModel profile;
  final int unreadCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onAchievements;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.main600,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Row(
              children: [
                _Avatar(url: profile.image),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أهلا بعودك , ${profile.fullName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font14Medium
                            .copyWith(color: AppColors.white),
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 4.h,
                        children: [
                          _Stat(
                            icon: PhosphorIconsRegular.star,
                            text: '${profile.points} نقطة',
                          ),
                          _Stat(
                            icon: PhosphorIconsRegular.trophy,
                            text: '${profile.medals} ميدالية',
                          ),
                          _Stat(
                            icon: PhosphorIconsRegular.books,
                            text: '${profile.packageCount} دورات',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _HeaderButton(
                  icon: PhosphorIconsRegular.bell,
                  showDot: unreadCount > 0,
                  onTap: onNotifications,
                ),
                SizedBox(width: 8.w),
                _HeaderButton(
                  icon: PhosphorIconsRegular.medal,
                  onTap: onAchievements,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final size = 48.w;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.second100,
      ),
      child: ClipOval(
        child: AppNetworkImage(
          url: url,
          width: size,
          height: size,
          fallbackAsset: 'assets/images/icon1.png',
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.w,
      children: [
        Icon(icon, size: 14.w, color: AppColors.white),
        Text(
          text,
          style: AppTextStyles.font12Regular.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, this.showDot = false, this.onTap});

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);
    return Material(
      color: AppColors.second500,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20.w, color: AppColors.white),
              if (showDot)
                PositionedDirectional(
                  top: 7.w,
                  end: 8.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.second500, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
