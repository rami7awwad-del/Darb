import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_sheet.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';
import 'package:darb/features/support/data/models/about_model.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:darb/features/support/presentation/cubit/about_cubit.dart';

/// Shows about sheet.
Future<void> showAboutSheet(BuildContext context) {
  final repository = context.read<SupportRepository>();
  return showAppSheet<void>(
    context,
    title: 'حول التطبيق',
    icon: ProfileIcons.about,
    builder: (_) => BlocProvider(
      create: (_) => AboutCubit(repository)..load(),
      child: const _AboutBody(),
    ),
  );
}

/// Body content of the about.
class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, BaseState<AboutModel>>(
      builder: (context, state) {
        if (state.stateValue == StateValue.loading) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.main600),
            ),
          );
        }
        if (state.stateValue == StateValue.error) {
          return SizedBox(
            height: 200.h,
            child: AppLoadError(
              message: state.errorMessage,
              onRetry: context.read<AboutCubit>().load,
            ),
          );
        }
        final about = state.data!;
        final links = about.links;
        final socials = <(IconData, Color, String?)>[
          (ProfileIcons.facebook, const Color(0xFF1877F2), links.facebook),
          (ProfileIcons.instagram, const Color(0xFFE1306C), links.instagram),
          (ProfileIcons.telegram, const Color(0xFF2AABEE), links.telegram),
          (ProfileIcons.whatsapp, const Color(0xFF25D366), links.whatsapp),
        ].where((s) => s.$3 != null).toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 104.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12.h),
            if (about.text.isNotEmpty)
              Text(
                about.text,
                textAlign: TextAlign.center,
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.main600,
                ),
              ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12.w,
              children: [
                for (final s in socials)
                  _SocialButton(icon: s.$1, color: s.$2, url: s.$3!),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Button widget for the social.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.url,
  });

  final IconData icon;
  final Color color;
  final String url;

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: _open,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 22.w, color: AppColors.white),
      ),
    );
  }
}
