import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/widgets/app_sheet.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/core/widgets/app_text_field.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:darb/features/support/presentation/cubit/contact_cubit.dart';

/// ورقة "تواصل معنا": الاسم، الكنية، الرقم، الوصف. [profile] يملأ الحقول مسبقًا.
/// 📏 القياسات: من [showAppSheet]، المسافة بين الحقول (24 رأسيًا، 12 أفقيًا)،
/// ارتفاع حقل الوصف (5 أسطر ≈ 128 في Figma).
Future<void> showContactSheet(BuildContext context, {ProfileModel? profile}) {
  final repository = context.read<SupportRepository>();
  return showAppSheet<void>(
    context,
    title: 'تواصل معنا',
    icon: ProfileIcons.contact,
    builder: (_) => BlocProvider(
      create: (_) => ContactCubit(repository),
      child: _ContactForm(profile: profile),
    ),
  );
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({this.profile});

  final ProfileModel? profile;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName =
      TextEditingController(text: widget.profile?.firstName);
  late final _lastName = TextEditingController(text: widget.profile?.lastName);
  late final _phone = TextEditingController(text: widget.profile?.phone);
  final _text = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _text.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ContactCubit>().send(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          phone: _phone.text.trim(),
          text: _text.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactCubit, BaseState<bool>>(
      listenWhen: (a, b) => a.stateValue != b.stateValue,
      listener: (context, state) {
        if (state.stateValue == StateValue.error) {
          showAppSnackBar(context, state.errorMessage ?? '');
        } else if (state.stateValue == StateValue.loaded) {
          showAppSnackBar(context, 'تم إرسال رسالتك بنجاح', isError: false);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final sending = state.stateValue == StateValue.loading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12.w, // 📏
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstName,
                      hint: 'الاسم',
                      prefixIcon: Icon(ProfileIcons.user),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                      enabled: !sending,
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _lastName,
                      hint: 'الكنية',
                      prefixIcon: Icon(ProfileIcons.user),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                      enabled: !sending,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h), // 📏
              AppTextField(
                controller: _phone,
                hint: 'الرقم',
                prefixIcon: Icon(ProfileIcons.phone),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _required,
                enabled: !sending,
              ),
              SizedBox(height: 24.h), // 📏
              AppTextField(
                controller: _text,
                hint: 'الوصف...',
                prefixIcon: Icon(ProfileIcons.description),
                keyboardType: TextInputType.multiline,
                minLines: 5, // 📏 يعطي ارتفاعًا قريبًا من 128
                maxLines: 5,
                validator: _required,
                enabled: !sending,
              ),
              SizedBox(height: 24.h), // 📏
              AppSheetActions(
                primaryText: 'التأكد',
                isLoading: sending,
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
