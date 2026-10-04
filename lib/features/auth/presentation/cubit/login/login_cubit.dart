import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginInitial());

  final AuthRepository _repository;

  Future<void> login(String phone) async {
    if (state is LoginLoading) return;

    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    emit(const LoginLoading());
    try {
      await _repository.login(cleaned);
      emit(LoginSuccess(cleaned));
    } on RemoteExceptions catch (e) {
      emit(LoginFailure(e.errorMsg));
    } catch (_) {
      emit(LoginFailure(ErrorCode.UNKNOWN.getLocalizedMessage()));
    }
  }
}
