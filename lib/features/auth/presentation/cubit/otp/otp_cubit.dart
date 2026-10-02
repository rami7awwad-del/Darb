import 'dart:async';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/repositories/auth_repository%20.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._repository, {required this.phone})
      : super(const OtpState(secondsLeft: resendSeconds)) {
    _startTimer();
  }

  /// ⚠️ مدة العدّاد: لقطة Figma تُظهر 00:55 أثناء العدّ، فاعتمدت 60 ثانية.
  static const int resendSeconds = 60;

  final AuthRepository _repository;
  final String phone;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.secondsLeft - 1;
      if (left <= 0) timer.cancel();
      emit(state.copyWith(secondsLeft: left < 0 ? 0 : left));
    });
  }

  Future<void> verify(String code) async {
    if (state.status == OtpStatus.verifying) return;

    // نرسل الأرقام فقط (الكولكشن فيه محرف مخفي قبل الرمز).
    final cleaned = code.replaceAll(RegExp(r'\D'), '');
    emit(state.copyWith(status: OtpStatus.verifying));
    try {
      final result = await _repository.activate(phone, cleaned);
      if (isClosed) return;
      emit(state.copyWith(
        status: OtpStatus.verified,
        isNewUser: result.needsProfileCompletion,
      ));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: OtpStatus.failure, message: e.errorMsg));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: OtpStatus.failure,
        message: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }

  Future<void> resend() async {
    if (state.secondsLeft > 0 || state.status == OtpStatus.resending) return;

    emit(state.copyWith(status: OtpStatus.resending));
    try {
      await _repository.resend(phone);
      if (isClosed) return;
      emit(state.copyWith(
        status: OtpStatus.resent,
        secondsLeft: resendSeconds,
      ));
      _startTimer();
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: OtpStatus.failure, message: e.errorMsg));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: OtpStatus.failure,
        message: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
