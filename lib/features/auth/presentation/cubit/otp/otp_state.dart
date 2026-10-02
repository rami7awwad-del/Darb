part of 'otp_cubit.dart';

enum OtpStatus { idle, verifying, verified, resending, resent, failure }

/// حالة واحدة (وليست sealed) لأن العدّاد يجب أن يعمل بالتوازي مع
/// حالة التفعيل/الإعادة. الشاشة تستمع فقط عند تغيّر [status].
class OtpState {
  const OtpState({
    this.status = OtpStatus.idle,
    required this.secondsLeft,
    this.message,
    this.isNewUser = false,
  });

  final OtpStatus status;
  final int secondsLeft;
  final String? message;
  final bool isNewUser;

  OtpState copyWith({
    OtpStatus? status,
    int? secondsLeft,
    String? message,
    bool? isNewUser,
  }) =>
      OtpState(
        status: status ?? this.status,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        message: message,
        isNewUser: isNewUser ?? this.isNewUser,
      );
}
