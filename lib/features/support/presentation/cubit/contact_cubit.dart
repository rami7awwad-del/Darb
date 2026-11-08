import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that manages the contact state.
class ContactCubit extends Cubit<BaseState<bool>> {
  ContactCubit(this._repository) : super(const BaseState<bool>());

  final SupportRepository _repository;

  Future<void> send({
    required String firstName,
    required String lastName,
    required String phone,
    required String text,
  }) async {
    if (state.stateValue == StateValue.loading) return;
    emit(const BaseState<bool>(stateValue: StateValue.loading));
    try {
      await _repository.sendContact(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        text: text,
      );
      if (isClosed) return;
      emit(const BaseState<bool>(stateValue: StateValue.loaded, data: true));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(BaseState<bool>(
        stateValue: StateValue.error,
        errorMessage: e.errorMsg,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(BaseState<bool>(
        stateValue: StateValue.error,
        errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
