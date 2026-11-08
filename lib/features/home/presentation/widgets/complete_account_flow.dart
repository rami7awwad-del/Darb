import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/home/presentation/cubit/complete_account_cubit.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:darb/features/home/presentation/widgets/complete_account_dialog.dart';
import 'package:darb/features/home/presentation/widgets/complete_account_sheet.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';

/// Shows complete account flow.
Future<void> showCompleteAccountFlow(BuildContext context) async {
  final homeCubit = context.read<HomeCubit>();
  final profileRepository = context.read<ProfileRepository>();
  final registrationRepository = context.read<RegistrationRepository>();

  final proceed = await showDialog<bool>(
    context: context,
    builder: (_) => const CompleteAccountDialog(),
  );
  if (proceed != true || !context.mounted) return;

  final profile = await showModalBottomSheet<ProfileModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => CompleteAccountCubit(
        profileRepository,
        registrationRepository,
      )..loadSchools(),
      child: const CompleteAccountSheet(),
    ),
  );
  if (profile == null) return;

  homeCubit.updateProfile(profile);
  if (context.mounted) {
    showAppSnackBar(context, 'تم تحديث بياناتك بنجاح', isError: false);
  }
}
