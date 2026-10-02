import 'package:darb/core/widget/app_primary_button.dart';
import 'package:darb/core/widget/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:darb/features/auth/presentation/widgets/auth_header.dart';
import 'package:darb/features/auth/presentation/widgets/otp_input_row.dart';
import 'package:darb/features/auth/presentation/widgets/resend_timer.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _codeLength = 4;

  final _otpKey = GlobalKey<OtpInputRowState>();
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OtpCubit, OtpState>(
        // نستمع فقط عند تغيّر الحالة (وليس مع كل ثانية من العدّاد).
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == OtpStatus.failure) {
            showAppSnackBar(context, state.message ?? '');
          } else if (state.status == OtpStatus.resent) {
            _otpKey.currentState?.clear();
            showAppSnackBar(context, 'تم إرسال الرمز مجددًا', isError: false);
          } else if (state.status == OtpStatus.verified) {
            // TODO: عند إنشاء الشاشتين:
            // Navigator.pushNamedAndRemoveUntil(
            //   context,
            //   state.isNewUser ? AppRoutes.register : AppRoutes.mainLayout,
            //   (_) => false,
            // );
            showAppSnackBar(
              context,
              state.isNewUser
                  ? 'تم التفعيل: مستخدم جديد (إكمال البيانات)'
                  : 'تم التفعيل: مستخدم موجود (الرئيسية)',
              isError: false,
            );
          }
        },
        builder: (context, state) {
          final isVerifying = state.status == OtpStatus.verifying;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const AuthHeader(showBack: true),
                // ⚠️ قياس تقديري: المسافة بين الترويسة والبطاقة (20)
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.5.w),
                  child: AuthCard(
                    children: [
                      const AuthTitle(first: 'أدخل', second: 'رمز التحقق'),
                      Text(
                        'أدخل الرمز الذي أُرسل إلى الرقم : ${widget.phone}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Regular
                            .copyWith(color: AppColors.grey400),
                      ),
                      OtpInputRow(
                        key: _otpKey,
                        length: _codeLength,
                        enabled: !isVerifying,
                        onChanged: (code) => setState(() => _code = code),
                      ),
                      ResendTimer(
                        secondsLeft: state.secondsLeft,
                        isResending: state.status == OtpStatus.resending,
                        onResend: () => context.read<OtpCubit>().resend(),
                      ),
                      AppPrimaryButton(
                        text: 'التأكيد',
                        isLoading: isVerifying,
                        onPressed: _code.length == _codeLength
                            ? () => context.read<OtpCubit>().verify(_code)
                            : null,
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
