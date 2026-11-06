import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_sizes.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/style/phosphor_icons.dart';
import 'package:darb/core/widgets/app_dropdown_field.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_text_field.dart';
import 'package:darb/features/home/presentation/cubit/complete_account_cubit.dart';

/// Bottom sheet for the complete account.
class CompleteAccountSheet extends StatelessWidget {
  const CompleteAccountSheet({super.key});

  static const List<(int, String)> _genders = [(1, 'ذكر'), (0, 'أنثى')];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompleteAccountCubit>();

    return BlocConsumer<CompleteAccountCubit, BaseState<CompleteAccountData>>(
      listenWhen: (p, c) =>
          p.data?.submitStatus != c.data?.submitStatus &&
          c.stateValue == StateValue.loaded &&
          c.data?.submitStatus == SubmitStatus.success,
      listener: (context, state) => Navigator.pop(context, state.data!.result),
      builder: (context, state) {
        final data = state.data!;
        final submitting = data.submitStatus == SubmitStatus.submitting;
        final schoolsLoading = data.schoolsStateValue == StateValue.loading;
        final schoolsReady = data.schoolsStateValue == StateValue.loaded;

        return PopScope(
          canPop: !submitting,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(
              16.w,
              24.h,
              16.w,
              24.h + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.user,
                      size: 24.w,
                      color: AppColors.second500,
                    ),
                    AppGaps.gapW8,
                    Expanded(
                      child: Text(
                        'أكمل حسابك',
                        style: AppTextStyles.font20Medium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: submitting ? null : () => Navigator.pop(context),
                      child: Icon(
                        PhosphorIconsRegular.x,
                        size: 32.w,
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
                AppGaps.gapH24,

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'الاسم',
                        prefixIcon: Icon(PhosphorIconsRegular.user),
                        textInputAction: TextInputAction.next,
                        enabled: !submitting,
                        onChanged: cubit.firstNameChanged,
                      ),
                    ),
                    AppGaps.gapW12,
                    Expanded(
                      child: AppTextField(
                        hint: 'الكنية',
                        prefixIcon: Icon(PhosphorIconsRegular.user),
                        textInputAction: TextInputAction.done,
                        enabled: !submitting,
                        onChanged: cubit.lastNameChanged,
                      ),
                    ),
                  ],
                ),
                AppGaps.gapH24,

                if (data.schoolsStateValue == StateValue.error)
                  _SchoolsError(
                    message: data.schoolsMessage,
                    onRetry: cubit.loadSchools,
                  )
                else
                  AppDropdownField<int>(
                    hint: schoolsLoading ? 'جاري تحميل المدارس...' : 'المدرسة',
                    prefixIcon: Icon(PhosphorIconsRegular.graduationCap),
                    items: [
                      for (final school in data.schools)
                        DropdownMenuItem<int>(
                          value: school.id,
                          child: Text(
                            school.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: schoolsReady && !submitting
                        ? cubit.schoolChanged
                        : null,
                  ),
                AppGaps.gapH24,

                AppDropdownField<int>(
                  hint: 'الجنس',
                  prefixIcon: Icon(PhosphorIconsRegular.users),
                  items: [
                    for (final (value, label) in _genders)
                      DropdownMenuItem<int>(value: value, child: Text(label)),
                  ],
                  onChanged: submitting ? null : cubit.genderChanged,
                ),
                AppGaps.gapH24,

                if (data.submitStatus == SubmitStatus.failure &&
                    state.errorMessage != null) ...[
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  AppGaps.gapH12,
                ],

                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        text: 'التأكيد',
                        isLoading: submitting,
                        onPressed: data.canSubmit ? cubit.submit : null,
                      ),
                    ),
                    AppGaps.gapW16,
                    Expanded(
                      child: AppOutlineButton(
                        text: 'الخروج',
                        onPressed: submitting
                            ? null
                            : () => Navigator.pop(context),
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

/// Error message shown when the schools fail to load.
class _SchoolsError extends StatelessWidget {
  const _SchoolsError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.danger, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message ?? 'تعذر تحميل المدارس',
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
          InkWell(
            onTap: onRetry,
            child: Text(
              'إعادة المحاولة',
              style: AppTextStyles.font12Medium.copyWith(
                color: AppColors.main600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
