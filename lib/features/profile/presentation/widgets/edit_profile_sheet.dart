import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/widgets/app_dropdown_field.dart';
import 'package:darb/core/widgets/app_sheet.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/core/widgets/app_text_field.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:darb/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';

/// Shows edit profile sheet.
Future<void> showEditProfileSheet(
  BuildContext context, {
  required ProfileModel profile,
  required ValueChanged<ProfileModel> onUpdated,
}) {
  final profileRepository = context.read<ProfileRepository>();
  final registrationRepository = context.read<RegistrationRepository>();

  return showAppSheet<void>(
    context,
    title: 'عدل معلوماتك الشخصية',
    icon: ProfileIcons.editProfile,
    builder: (_) => BlocProvider(
      create: (_) =>
          EditProfileCubit(profileRepository, registrationRepository)
            ..loadSchools(),
      child: _EditProfileForm(profile: profile, onUpdated: onUpdated),
    ),
  );
}

/// Widget that shows the edit profile form.
class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({required this.profile, required this.onUpdated});

  final ProfileModel profile;
  final ValueChanged<ProfileModel> onUpdated;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

/// State for the edit profile form widget.
class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.profile.firstName);
  late final _lastName = TextEditingController(text: widget.profile.lastName);
  late int? _schoolId = widget.profile.schoolId;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EditProfileCubit>().save(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          schoolId: _schoolId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, BaseState<EditProfileData>>(
      listenWhen: (a, b) => a.stateValue != b.stateValue,
      listener: (context, state) {
        if (state.stateValue == StateValue.error) {
          showAppSnackBar(context, state.errorMessage ?? '');
        } else if (state.stateValue == StateValue.loaded) {
          final updated = state.data?.updated;
          if (updated != null) widget.onUpdated(updated);
          showAppSnackBar(context, 'تم تعديل البيانات بنجاح', isError: false);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final data = state.data!;
        final saving = state.stateValue == StateValue.loading;
        final schoolValue = data.schools.any((s) => s.id == _schoolId)
            ? _schoolId
            : null;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12.w,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstName,
                      hint: 'الاسم',
                      prefixIcon: Icon(ProfileIcons.user),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                      enabled: !saving,
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _lastName,
                      hint: 'الكنية',
                      prefixIcon: Icon(ProfileIcons.user),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                      enabled: !saving,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              AppDropdownField<int>(
                key: ValueKey('schools-${data.schools.length}'),
                hint: data.schoolsLoading ? 'جارٍ تحميل المدارس...' : 'المدرسة',
                prefixIcon: Icon(ProfileIcons.school),
                value: schoolValue,
                items: [
                  for (final school in data.schools)
                    DropdownMenuItem<int>(
                      value: school.id,
                      child: Text(school.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: saving ? null : (v) => setState(() => _schoolId = v),
                validator: (v) => v == null ? 'اختر المدرسة' : null,
              ),
              SizedBox(height: 24.h),
              AppSheetActions(
                primaryText: 'عدل',
                isLoading: saving,
                onPrimary: _submit,
                onSecondary: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
