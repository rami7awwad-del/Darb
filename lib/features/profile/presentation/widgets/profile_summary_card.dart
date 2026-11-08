import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';

/// Card widget for the profile summary.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.profile,
    this.topGap = 28,
  });

  final ProfileModel profile;
  final double topGap;

  static const double _avatar = 160;
  static const double _protrude = 40;

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar.w;
    final protrude = _protrude.h;

    return Padding(
      padding: EdgeInsets.only(top: topGap.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: protrude),
            padding: EdgeInsets.fromLTRB(
              16.w,
              avatar - protrude + 8.h,
              16.w,
              16.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.grey50),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font20Medium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1, color: AppColors.grey50),
                SizedBox(height: 12.h),
                _StatsRow(profile: profile),
              ],
            ),
          ),
          Container(
            width: avatar,
            height: avatar,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.second100,
            ),
            child: ClipOval(
              child: AppNetworkImage(
                url: profile.image,
                width: avatar,
                height: avatar,
                fallbackAsset: 'assets/images/icon1.png',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row widget for the stats.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final items = <(int, String)>[
      (profile.semesterCount, 'الفصول'),
      (profile.points, 'النقاط'),
      (profile.packageCount, 'الدورات'),
      (profile.subjectCount, 'الدروس'),
      (profile.medals, 'الأوسمة'),
    ];

    return IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.grey50,
                indent: 2.h,
                endIndent: 2.h,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${items[i].$1}',
                    style: AppTextStyles.font16Medium.copyWith(
                      color: AppColors.main600,
                    ),
                  ),
                  Text(
                    items[i].$2,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.grey300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
