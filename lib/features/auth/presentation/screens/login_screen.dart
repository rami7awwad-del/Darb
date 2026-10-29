import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/core/widgets/app_text_field.dart' show AppTextField;
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:darb/features/auth/presentation/widgets/auth_header.dart';
import 'package:darb/core/routing/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// TODO: عدّل قواعد التحقق حسب صيغة الأرقام المعتمدة (الكولكشن: 0993571184).
  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'أدخل رقم هاتفك';
    if (phone.length < 9) return 'رقم الهاتف غير صحيح';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginCubit, BaseState<String>>(
        listener: (context, state) {
          if (state.stateValue == StateValue.loaded) {
            Navigator.pushNamed(context, AppRoutes.otp, arguments: state.data!);
          } else if (state.stateValue == StateValue.error) {
            showAppSnackBar(context, state.errorMessage ?? '');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const AuthHeader(),
                SizedBox(height: 31.h), //  258-227
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.5.w),
                  child: AuthCard(
                    children: [
                      const AuthTitle(first: 'أدخل إلى', second: 'حسابك'),
                      Text(
                        'أهلاً بك من جديد ! سجّل دخولك للمتابعة',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Medium.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: AppTextField(
                          controller: _phoneController,
                          hint: 'أدخل رقم هاتفك',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: _validatePhone,
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      AppPrimaryButton(
                        text: 'سجّل دخولك',
                        isLoading: state.stateValue == StateValue.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
