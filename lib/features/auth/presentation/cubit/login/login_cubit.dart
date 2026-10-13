import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<BaseState<String>> {
  LoginCubit(this._repository) : super(const BaseState<String>());

  final AuthRepository _repository;

  Future<void> login(String phone) async {
    if (state.stateValue == StateValue.loading) return;

    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    emit(const BaseState<String>(stateValue: StateValue.loading));
    try {
      await _repository.login(cleaned);
      emit(BaseState<String>(stateValue: StateValue.loaded, data: cleaned));
    } on RemoteExceptions catch (e) {
      emit(
        BaseState<String>(
          stateValue: StateValue.error,
          errorMessage: e.errorMsg,
        ),
      );
    } catch (_) {
      emit(
        BaseState<String>(
          stateValue: StateValue.error,
          errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
        ),
      );
    }
  }
}
