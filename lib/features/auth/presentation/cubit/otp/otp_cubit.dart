import 'dart:async';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Possible values for the otp status.
enum OtpStatus { idle, verifying, verified, resending, resent, failure }

/// State data for the otp.
class OtpData {
  const OtpData({
    this.status = OtpStatus.idle,
    required this.secondsLeft,
    this.isNewUser = false,
  });

  final OtpStatus status;
  final int secondsLeft;
  final bool isNewUser;

  /// Returns a copy with the given fields replaced.
  OtpData copyWith({OtpStatus? status, int? secondsLeft, bool? isNewUser}) =>
      OtpData(
        status: status ?? this.status,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        isNewUser: isNewUser ?? this.isNewUser,
      );
}

/// Cubit that manages the otp state.
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

  static const int resendSeconds = 60;

  final AuthRepository _repository;
  final String phone;
  Timer? _timer;

  /// Starts timer.
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

  /// Checks the entered code with the server.
  Future<void> verify(String code) async {
    if (state.data!.status == OtpStatus.verifying) return;

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

  /// Requests a new code.
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

  /// Stops background work before the cubit closes.
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
