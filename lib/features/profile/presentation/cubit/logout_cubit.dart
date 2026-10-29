import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// تسجيل الخروج. loaded = تم حذف التوكن، والشاشة تنقل المستخدم لشاشة الدخول.
class LogoutCubit extends Cubit<BaseState<bool>> {
  LogoutCubit(this._repository) : super(const BaseState<bool>());

  final AuthRepository _repository;

  Future<void> logout() async {
    if (state.stateValue == StateValue.loading) return;
    emit(const BaseState<bool>(stateValue: StateValue.loading));
    try {
      await _repository.logout();
      if (isClosed) return;
      emit(const BaseState<bool>(stateValue: StateValue.loaded, data: true));
    } catch (_) {
      if (isClosed) return;
      emit(BaseState<bool>(
        stateValue: StateValue.error,
        errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
