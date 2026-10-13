import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:darb/features/auth/presentation/widgets/auth_header.dart';
import 'package:darb/features/auth/presentation/widgets/register_steps.dart';
import 'package:darb/features/auth/presentation/widgets/terms_sheet.dart';


/// معالج إكمال البيانات: شاشة واحدة تبدّل الخطوات حسب [RegisterCubit].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.phone});

  final String phone;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  late final _phone = TextEditingController(text: widget.phone);
  bool _openingTerms = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _onPersonalNext() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<RegisterCubit>();
    if (!cubit.state.data!.termsAccepted) {
      showAppSnackBar(context, 'يجب الموافقة على الشروط والأحكام');
      return;
    }
    cubit.savePersonalInfo(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
    );
  }

  Future<void> _openTerms() async {
    if (_openingTerms) return;
    _openingTerms = true;
    final terms = await context.read<RegisterCubit>().loadTerms();
    _openingTerms = false;
    if (!mounted) return;

    if (terms == null) {
      showAppSnackBar(context, 'تعذر تحميل الشروط والأحكام، حاول مرة أخرى');
      return;
    }
    await showTermsSheet(context, terms);
  }

  Widget _buildBody(BuildContext context, BaseState<RegisterData> state) {
    final data = state.data!;
    if (state.stateValue == StateValue.loading &&
        data.status == RegisterStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.main600),
      );
    }

    if (state.stateValue == StateValue.error &&
        data.status == RegisterStatus.loadFailed) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.h,
            children: [
              Text(
                state.errorMessage ?? 'تعذر تحميل البيانات',
                textAlign: TextAlign.center,
                style: AppTextStyles.font14Regular.copyWith(
                  color: AppColors.grey400,
                ),
              ),
              AppOutlineButton(
                text: 'إعادة المحاولة',
                onPressed: context.read<RegisterCubit>().loadInitial,
              ),
            ],
          ),
        ),
      );
    }

    return switch (data.step) {
      RegisterStep.personal => PersonalInfoStep(
        state: data,
        formKey: _formKey,
        firstNameController: _firstName,
        lastNameController: _lastName,
        emailController: _email,
        phoneController: _phone,
        onNext: _onPersonalNext,
        onOpenTerms: _openTerms,
      ),
      RegisterStep.source => SourceStep(state: data),
      RegisterStep.gender => GenderStep(state: data),
      RegisterStep.age => AgeStep(state: data),
      RegisterStep.institution => InstitutionStep(state: data),
      RegisterStep.branch => BranchStep(state: data),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, BaseState<RegisterData>>(
      listenWhen: (previous, current) =>
          previous.data?.status != current.data?.status,
      listener: (context, state) {
        final data = state.data!;
        if (state.stateValue == StateValue.error &&
            data.status == RegisterStatus.submitFailed) {
          showAppSnackBar(context, state.errorMessage ?? '');
        } else if (state.stateValue == StateValue.loaded &&
            data.status == RegisterStatus.submitted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.registerSuccess,
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        final isFirstStep = state.data!.step == RegisterStep.personal;

        return PopScope(
          // زر الرجوع (النظام أو السهم) يرجع خطوة، ويخرج فقط من الخطوة الأولى.
          canPop: isFirstStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<RegisterCubit>().back();
          },
          child: Scaffold(
            body: Column(
              children: [
                // السهم يظهر من الخطوة الثانية فما فوق (لا رجوع من الأولى إلى OTP).
                AuthHeader(showBack: !isFirstStep),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: _buildBody(context, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
