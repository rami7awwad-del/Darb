import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SubmitStatus { idle, submitting, success, failure }

class CompleteAccountData {
  const CompleteAccountData({
    this.schoolsStateValue = StateValue.loading,
    this.submitStatus = SubmitStatus.idle,
    this.schools = const [],
    this.firstName = '',
    this.lastName = '',
    this.schoolId,
    this.gender,
    this.schoolsMessage,
    this.result,
  });

  final StateValue schoolsStateValue;
  final SubmitStatus submitStatus;
  final List<SchoolModel> schools;
  final String firstName;
  final String lastName;
  final int? schoolId;
  final int? gender;
  final String? schoolsMessage;
  final ProfileModel? result;

  /// كل الحقول إلزامية، ولا يُرسل طلب ثانٍ أثناء الإرسال.
  bool get canSubmit =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      schoolId != null &&
      gender != null &&
      submitStatus != SubmitStatus.submitting;

  CompleteAccountData copyWith({
    StateValue? schoolsStateValue,
    SubmitStatus? submitStatus,
    List<SchoolModel>? schools,
    String? firstName,
    String? lastName,
    int? schoolId,
    int? gender,
    String? schoolsMessage,
    ProfileModel? result,
  }) => CompleteAccountData(
    schoolsStateValue: schoolsStateValue ?? this.schoolsStateValue,
    submitStatus: submitStatus ?? this.submitStatus,
    schools: schools ?? this.schools,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    schoolId: schoolId ?? this.schoolId,
    gender: gender ?? this.gender,
    schoolsMessage: schoolsMessage,
    result: result ?? this.result,
  );
}

/// نافذة "أكمل حسابك" في الرئيسية: تحمّل المدارس وترسل التعديل.
class CompleteAccountCubit extends Cubit<BaseState<CompleteAccountData>> {
  CompleteAccountCubit(this._profile, this._registration)
    : super(
        const BaseState<CompleteAccountData>(
          stateValue: StateValue.loading,
          data: CompleteAccountData(),
        ),
      );

  final ProfileRepository _profile;
  final RegistrationRepository _registration;

  CompleteAccountData get _data => state.data!;

  void _updateForm(CompleteAccountData data) {
    emit(
      state.copyWith(
        stateValue: StateValue.loaded,
        data: data.copyWith(submitStatus: SubmitStatus.idle),
        clearErrorMessage: true,
      ),
    );
  }

  /// GET schools/all (بدون معاملات).
  Future<void> loadSchools() async {
    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: _data.copyWith(
          schoolsStateValue: StateValue.loading,
          schoolsMessage: null,
        ),
        clearErrorMessage: true,
      ),
    );
    try {
      final schools = await _registration.getSchools();
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            schoolsStateValue: StateValue.loaded,
            schools: schools,
            schoolsMessage: null,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      _onSchoolsError(e.errorMsg);
    } catch (_) {
      _onSchoolsError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onSchoolsError(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        stateValue: StateValue.error,
        data: _data.copyWith(
          schoolsStateValue: StateValue.error,
          schoolsMessage: message,
        ),
      ),
    );
  }

  void firstNameChanged(String value) =>
      _updateForm(_data.copyWith(firstName: value));

  void lastNameChanged(String value) =>
      _updateForm(_data.copyWith(lastName: value));

  void schoolChanged(int? id) => _updateForm(_data.copyWith(schoolId: id));

  void genderChanged(int? value) => _updateForm(_data.copyWith(gender: value));

  /// POST users/update. عند النجاح تحمل الحالة الملف الشخصي المحدّث في [result].
  Future<void> submit() async {
    if (!_data.canSubmit) return;
    final data = _data;
    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: data.copyWith(submitStatus: SubmitStatus.submitting),
        clearErrorMessage: true,
      ),
    );
    try {
      final profile = await _profile.updateProfile(
        firstName: data.firstName.trim(),
        lastName: data.lastName.trim(),
        schoolId: data.schoolId!,
        gender: data.gender!,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            submitStatus: SubmitStatus.success,
            result: profile,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      _onSubmitError(e.errorMsg);
    } catch (_) {
      _onSubmitError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onSubmitError(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        stateValue: StateValue.error,
        data: _data.copyWith(submitStatus: SubmitStatus.failure),
        errorMessage: message,
      ),
    );
  }
}
