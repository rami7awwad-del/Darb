import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// تبويب الملف الشخصي. يُنشأ مع مسار mainLayout (مثل بقية التبويبات).
class ProfileCubit extends Cubit<BaseState<ProfileModel>> {
  ProfileCubit(this._repository)
      : super(const BaseState<ProfileModel>(stateValue: StateValue.loading));

  final ProfileRepository _repository;

  /// [silent] = true للسحب للتحديث (بدون مؤشر التحميل الكامل).
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

  void _onError(String message) {
    if (isClosed) return;
    // فشل تحديث صامت مع وجود بيانات سابقة: نُبقي ما هو معروض.
    if (state.data != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  /// بعد نجاح تعديل البيانات: نعرض الملف المحدّث مباشرة.
  void replace(ProfileModel profile) {
    if (isClosed) return;
    emit(BaseState<ProfileModel>(stateValue: StateValue.loaded, data: profile));
  }
}
