import 'dart:async';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OtpStatus { idle, verifying, verified, resending, resent, failure }

class OtpData {
  const OtpData({
    this.status = OtpStatus.idle,
    required this.secondsLeft,
    this.isNewUser = false,
  });

  final OtpStatus status;
  final int secondsLeft;
  final bool isNewUser;

  OtpData copyWith({OtpStatus? status, int? secondsLeft, bool? isNewUser}) =>
      OtpData(
        status: status ?? this.status,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        isNewUser: isNewUser ?? this.isNewUser,
      );
}

class OtpCubit extends Cubit<BaseState<OtpData>> {
  OtpCubit(this._repository, {required this.phone})
    : super(
        const BaseState<OtpData>(
          stateValue: StateValue.init,
          data: OtpData(secondsLeft: resendSeconds),
        ),
      ) {
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
      final data = state.data!;
      final left = data.secondsLeft - 1;
      if (left <= 0) timer.cancel();
      emit(
        state.copyWith(data: data.copyWith(secondsLeft: left < 0 ? 0 : left)),
      );
    });
  }

  Future<void> verify(String code) async {
    if (state.data!.status == OtpStatus.verifying) return;

    // نرسل الأرقام فقط (الكولكشن فيه محرف مخفي قبل الرمز).
    final cleaned = code.replaceAll(RegExp(r'\D'), '');
    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: state.data!.copyWith(status: OtpStatus.verifying),
        clearErrorMessage: true,
      ),
    );
    try {
      final result = await _repository.activate(phone, cleaned);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: state.data!.copyWith(
            status: OtpStatus.verified,
            isNewUser: result.needsProfileCompletion,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      _emitFailure(e.errorMsg);
    } catch (_) {
      if (isClosed) return;
      _emitFailure(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  Future<void> resend() async {
    final data = state.data!;
    if (data.secondsLeft > 0 || data.status == OtpStatus.resending) return;

    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: data.copyWith(status: OtpStatus.resending),
        clearErrorMessage: true,
      ),
    );
    try {
      await _repository.resend(phone);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: state.data!.copyWith(
            status: OtpStatus.resent,
            secondsLeft: resendSeconds,
          ),
          clearErrorMessage: true,
        ),
      );
      _startTimer();
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      _emitFailure(e.errorMsg);
    } catch (_) {
      if (isClosed) return;
      _emitFailure(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _emitFailure(String message) {
    emit(
      state.copyWith(
        stateValue: StateValue.error,
        data: state.data!.copyWith(status: OtpStatus.failure),
        errorMessage: message,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
