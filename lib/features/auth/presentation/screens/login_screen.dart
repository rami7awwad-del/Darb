import 'package:darb/core/routing/app_routes%20.dart';
import 'package:darb/core/widget/app_primary_button.dart';
import 'package:darb/core/widget/app_snack_bar.dart';
import 'package:darb/core/widget/app_text_field%20.dart' show AppTextField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:darb/features/auth/presentation/widgets/auth_header.dart';

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
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushNamed(context, AppRoutes.otp, arguments: state.phone);
          } else if (state is LoginFailure) {
            showAppSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const AuthHeader(),
                // ⚠️ قياس تقديري: المسافة بين الترويسة والبطاقة (20)
                SizedBox(height: 20.h),
                Padding(
                  // Figma: البطاقة 405 من 430 → 12.5 من كل جانب
                  padding: EdgeInsets.symmetric(horizontal: 12.5.w),
                  child: AuthCard(
                    children: [
                      const AuthTitle(first: 'أدخل', second: 'إلى حسابك'),
                      // ⚠️ نص مؤقت: لم أستطع قراءة النص الفرعي في Figma، استبدله.
                      Text(
                        'سنرسل لك رمز التحقق عبر واتساب',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Regular.copyWith(
                          color: AppColors.grey300,
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
                        isLoading: state is LoginLoading,
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
