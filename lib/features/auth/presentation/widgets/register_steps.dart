import 'package:darb/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_dropdown_field.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';

import 'package:darb/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:darb/features/auth/presentation/widgets/age_counter.dart';
import 'package:darb/features/auth/presentation/widgets/auth_header.dart';
import 'package:darb/features/auth/presentation/widgets/choice_card.dart';
import 'package:darb/features/auth/presentation/widgets/register_options.dart';
import 'package:darb/features/auth/presentation/widgets/register_progress_bar.dart';
import 'package:darb/features/auth/presentation/widgets/step_heading.dart';
import 'package:darb/core/style/phosphor_icons.dart';

// ⚠️ قياس تقديري: هامش الصفحة 16 (البطاقة 397 من 430 في Figma)،
// والفراغ العلوي 20 والسفلي 24.
EdgeInsets get _cardPagePadding => EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h);

// ───────────────────────── إطار الخطوات (ج إلى و) ─────────────────────────

/// شريط التقدم + العنوان + المحتوى، والأزرار مثبّتة أسفل الشاشة.
class WizardPage extends StatelessWidget {
  const WizardPage({
    super.key,
    required this.stage,
    required this.child,
    required this.actions,
  });

  final int stage;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegisterProgressBar(stage: stage),
                SizedBox(height: 24.h),
                const StepHeading(
                  first: 'إستكمل',
                  second: 'معلوماتك',
                  subtitle: 'عبأ معلوماتك لإنشاء الحساب!',
                ),
                SizedBox(height: 24.h),
                child,
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          // ⚠️ قياس تقديري: المسافة بين الزرين (12)
          child: Row(
            spacing: 12.w,
            children: [for (final a in actions) Expanded(child: a)],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── (أ) البيانات الشخصية ─────────────────────────

class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({
    super.key,
    required this.state,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.onNext,
    required this.onOpenTerms,
  });

  final RegisterState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onNext;
  final VoidCallback onOpenTerms;

  String? _required(String? v, String message) =>
      (v ?? '').trim().isEmpty ? message : null;

  String? _email(String? v) {
    final email = (v ?? '').trim();
    if (email.isEmpty) return 'أدخل بريدك الإلكتروني';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'البريد الإلكتروني غير صحيح';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final schoolExists = state.schools.any((s) => s.id == state.schoolId);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _cardPagePadding,
      child: AuthCard(
        children: [
          const StepHeading(
            first: 'إستكمل',
            second: 'معلوماتك',
            subtitle: 'عبأ معلوماتك لإنشاء الحساب!',
            centered: true,
          ),
          Form(
            key: formKey,
            child: Column(
              spacing: 16.h,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12.w,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: firstNameController,
                        hint: 'الاسم',
                        prefixIcon: Icon(PhosphorIconsRegular.user),
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(v, 'أدخل اسمك'),
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: lastNameController,
                        hint: 'الكنية',
                        prefixIcon: Icon(PhosphorIconsRegular.user),
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(v, 'أدخل كنيتك'),
                      ),
                    ),
                  ],
                ),
                AppTextField(
                  controller: emailController,
                  hint: 'اكتب الإيميل',
                  prefixIcon: Icon(PhosphorIconsRegular.envelope),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _email,
                ),
                // الهاتف للعرض فقط (من تسجيل الدخول)
                AppTextField(
                  controller: phoneController,
                  prefixIcon: Icon(PhosphorIconsRegular.phone),
                  enabled: false,
                ),
                AppDropdownField<int>(
                  hint: 'المدرسة',
                  prefixIcon: Icon(PhosphorIconsRegular.graduationCap),
                  value: schoolExists ? state.schoolId : null,
                  items: [
                    for (final s in state.schools)
                      DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: cubit.setSchool,
                  validator: (v) => v == null ? 'اختر مدرستك' : null,
                ),
              ],
            ),
          ),
          _TermsCheckbox(
            accepted: state.termsAccepted,
            onChanged: cubit.setTermsAccepted,
            onOpenTerms: onOpenTerms,
          ),
          AppPrimaryButton(text: 'التالي', onPressed: onNext),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.accepted,
    required this.onChanged,
    required this.onOpenTerms,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
          height: 20.w,
          child: Checkbox(
            value: accepted,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.success,
            side: const BorderSide(color: AppColors.grey100),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'أنا أوافق على ',
                style: AppTextStyles.font12Regular.copyWith(color: AppColors.grey400),
              ),
              GestureDetector(
                onTap: onOpenTerms,
                child: Text(
                  'الشروط و الأحكام',
                  style: AppTextStyles.font12Medium.copyWith(
                    color: AppColors.main600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.main600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── (ب) كيف عرفت التطبيق؟ ─────────────────────────

class SourceStep extends StatelessWidget {
  const SourceStep({super.key, required this.state});

  final RegisterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final options = RegisterOptions.sources;
    const columns = 3;

    return SingleChildScrollView(
      padding: _cardPagePadding,
      child: AuthCard(
        children: [
          const StepHeading(
            first: 'كيفية',
            second: 'معرفتك بالتطبيق؟',
            centered: true,
          ),
          // شبكة 3 أعمدة (الفراغ بين البلاطات 8 = AppGrid.gutter)
          Column(
            spacing: 8.h,
            children: [
              for (var i = 0; i < options.length; i += columns)
                Row(
                  spacing: 8.w,
                  children: [
                    for (var j = i; j < i + columns; j++)
                      Expanded(
                        child: j < options.length
                            ? ChoiceTile(
                                label: options[j].label,
                                icon: options[j].icon,
                                selected: state.knowAboutApp == options[j].id,
                                onTap: () => cubit.selectSource(options[j].id),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
            ],
          ),
          AppPrimaryButton(
            text: 'التالي',
            onPressed: state.canProceed ? cubit.next : null,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── (ج) الجنس ─────────────────────────

class GenderStep extends StatelessWidget {
  const GenderStep({super.key, required this.state});

  final RegisterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return WizardPage(
      stage: state.stage,
      actions: [
        AppPrimaryButton(
          text: 'التالي',
          onPressed: state.canProceed ? cubit.next : null,
        ),
      ],
      child: Column(
        spacing: 11.h, // Figma: Gap 11
        children: [
          for (final o in RegisterOptions.genders)
            ChoiceCard(
              title: o.label,
              icon: o.icon,
              boxedIcon: false,
              selected: state.gender == o.id,
              onTap: () => cubit.selectGender(o.id),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── (د) العمر ─────────────────────────

class AgeStep extends StatelessWidget {
  const AgeStep({super.key, required this.state});

  final RegisterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return WizardPage(
      stage: state.stage,
      actions: [
        AppOutlineButton(text: 'الرجوع', onPressed: cubit.back),
        AppPrimaryButton(text: 'التالي', onPressed: cubit.next),
      ],
      child: AgeCounter(
        age: state.age,
        onIncrement: state.age < RegisterCubit.maxAge ? cubit.incrementAge : null,
        onDecrement: state.age > RegisterCubit.minAge ? cubit.decrementAge : null,
      ),
    );
  }
}

// ───────────────────────── (هـ) نوع المؤسسة ─────────────────────────

class InstitutionStep extends StatelessWidget {
  const InstitutionStep({super.key, required this.state});

  final RegisterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return WizardPage(
      stage: state.stage,
      actions: [
        AppPrimaryButton(
          text: 'التالي',
          onPressed: state.canProceed ? cubit.next : null,
        ),
      ],
      child: Column(
        spacing: 16.h,
        children: [
          for (final o in RegisterOptions.institutions)
            ChoiceCard(
              title: o.label,
              subtitle: o.description,
              icon: o.icon,
              large: true,
              selected: state.institutionType == o.id,
              onTap: () => cubit.selectInstitution(o.id),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── (و) الفرع ─────────────────────────

class BranchStep extends StatelessWidget {
  const BranchStep({super.key, required this.state});

  final RegisterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return WizardPage(
      stage: state.stage,
      actions: [
        AppPrimaryButton(
          text: 'التأكيد',
          isLoading: state.status == RegisterStatus.submitting,
          onPressed: state.canProceed ? cubit.submit : null,
        ),
      ],
      child: state.branches.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'لا توجد فروع متاحة حاليًا',
                textAlign: TextAlign.center,
                style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey300),
              ),
            )
          : Column(
              spacing: 12.h,
              children: [
                for (final b in state.branches)
                  ChoiceCard(
                    title: b.name,
                    icon: RegisterOptions.branchIcon,
                    selected: state.branchId == b.id,
                    onTap: () => cubit.selectBranch(b.id),
                  ),
              ],
            ),
    );
  }
}
