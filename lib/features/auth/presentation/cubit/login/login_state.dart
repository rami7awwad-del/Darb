part of 'login_cubit.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.phone);
  final String phone;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;
}
