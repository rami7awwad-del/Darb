import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that manages the profile state.
class ProfileCubit extends Cubit<BaseState<ProfileModel>> {
  ProfileCubit(this._repository)
      : super(const BaseState<ProfileModel>(stateValue: StateValue.loading));

  final ProfileRepository _repository;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    }
    try {
      final profile = await _repository.getProfile();
      if (isClosed) return;
      emit(BaseState<ProfileModel>(stateValue: StateValue.loaded, data: profile));
    } on RemoteExceptions catch (e) {
      _onError(e.errorMsg);
    } catch (_) {
      _onError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles error.
  void _onError(String message) {
    if (isClosed) return;
    if (state.data != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  void replace(ProfileModel profile) {
    if (isClosed) return;
    emit(BaseState<ProfileModel>(stateValue: StateValue.loaded, data: profile));
  }
}
