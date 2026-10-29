import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileData {
  const EditProfileData({
    this.schools = const [],
    this.schoolsLoading = true,
    this.updated,
  });

  final List<SchoolModel> schools;
  final bool schoolsLoading;

  /// الملف بعد التعديل (يُملأ عند النجاح).
  final ProfileModel? updated;

  EditProfileData copyWith({
    List<SchoolModel>? schools,
    bool? schoolsLoading,
    ProfileModel? updated,
  }) =>
      EditProfileData(
        schools: schools ?? this.schools,
        schoolsLoading: schoolsLoading ?? this.schoolsLoading,
        updated: updated ?? this.updated,
      );
}

/// ورقة تعديل المعلومات الشخصية.
/// stateValue = حالة الحفظ (loading أثناء الحفظ، loaded عند النجاح، error عند الفشل).
/// تحميل المدارس يتتبعه [EditProfileData.schoolsLoading].
class EditProfileCubit extends Cubit<BaseState<EditProfileData>> {
  EditProfileCubit(this._profile, this._registration)
      : super(const BaseState<EditProfileData>(data: EditProfileData()));

  final ProfileRepository _profile;
  final RegistrationRepository _registration;

  EditProfileData get _data => state.data!;

  Future<void> loadSchools() async {
    try {
      final schools = await _registration.getSchools();
      if (isClosed) return;
      emit(state.copyWith(
        data: _data.copyWith(schools: schools, schoolsLoading: false),
      ));
    } catch (_) {
      if (isClosed) return;
      // القائمة تبقى فارغة؛ الحقل يظهر معطّلًا ولا يمنع تعديل الاسم.
      emit(state.copyWith(data: _data.copyWith(schoolsLoading: false)));
    }
  }

  Future<void> save({
    required String firstName,
    required String lastName,
    required int schoolId,
  }) async {
    if (state.stateValue == StateValue.loading) return;
    emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    try {
      final profile = await _profile.updateProfile(
        firstName: firstName,
        lastName: lastName,
        schoolId: schoolId,
      );
      if (isClosed) return;
      emit(state.copyWith(
        stateValue: StateValue.loaded,
        data: _data.copyWith(updated: profile),
      ));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(state.copyWith(stateValue: StateValue.error, errorMessage: e.errorMsg));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        stateValue: StateValue.error,
        errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
