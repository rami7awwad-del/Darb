import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'complete_account_state.dart';

/// نافذة "أكمل حسابك" في الرئيسية: تحمّل المدارس وترسل التعديل.
class CompleteAccountCubit extends Cubit<CompleteAccountState> {
  CompleteAccountCubit(this._profile, this._registration)
      : super(const CompleteAccountState());

  final ProfileRepository _profile;
  final RegistrationRepository _registration;

  /// GET schools/all (بدون معاملات).
  Future<void> loadSchools() async {
    emit(state.copyWith(schoolsStatus: SchoolsStatus.loading));
    try {
      final schools = await _registration.getSchools();
      if (isClosed) return;
      emit(state.copyWith(
        schoolsStatus: SchoolsStatus.ready,
        schools: schools,
      ));
    } on RemoteExceptions catch (e) {
      _onSchoolsError(e.errorMsg);
    } catch (_) {
      _onSchoolsError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onSchoolsError(String message) {
    if (isClosed) return;
    emit(state.copyWith(
      schoolsStatus: SchoolsStatus.failure,
      schoolsMessage: message,
    ));
  }

  void firstNameChanged(String value) =>
      emit(state.copyWith(firstName: value));

  void lastNameChanged(String value) => emit(state.copyWith(lastName: value));

  void schoolChanged(int? id) => emit(state.copyWith(schoolId: id));

  void genderChanged(int? value) => emit(state.copyWith(gender: value));

  /// POST users/update. عند النجاح تحمل الحالة الملف الشخصي المحدّث في [result].
  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(submitStatus: SubmitStatus.submitting));
    try {
      final profile = await _profile.updateProfile(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        schoolId: state.schoolId!,
        gender: state.gender!,
      );
      if (isClosed) return;
      emit(state.copyWith(submitStatus: SubmitStatus.success, result: profile));
    } on RemoteExceptions catch (e) {
      _onSubmitError(e.errorMsg);
    } catch (_) {
      _onSubmitError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onSubmitError(String message) {
    if (isClosed) return;
    emit(state.copyWith(submitStatus: SubmitStatus.failure, message: message));
  }
}
