import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_circle_close_button.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:darb/features/profile/presentation/cubit/logout_cubit.dart';

/// Shows logout dialog.
Future<void> showLogoutDialog(BuildContext context) {
  final repository = context.read<AuthRepository>();
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => LogoutCubit(repository),
      child: const _LogoutDialog(),
    ),
  );
}

/// Dialog for the logout.
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, BaseState<bool>>(
      listenWhen: (a, b) => a.stateValue != b.stateValue,
      listener: (context, state) {
        if (state.stateValue == StateValue.loaded) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (_) => false,
          );
        } else if (state.stateValue == StateValue.error) {
          showAppSnackBar(context, state.errorMessage ?? '');
        }
      },
      builder: (context, state) {
        final loading = state.stateValue == StateValue.loading;
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تأكيد تسجيل الخروج',
                        style: AppTextStyles.font16Medium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                    AppCircleCloseButton(
                      onTap: loading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  spacing: 12.w,
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        text: 'التأكد',
                        isLoading: loading,
                        onPressed: () =>
                            context.read<LogoutCubit>().logout(),
                      ),
                    ),
                    Expanded(
                      child: AppOutlineButton(
                        text: 'الرجوع',
                        onPressed: loading ? null : () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
