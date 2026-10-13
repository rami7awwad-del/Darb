import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/models/branch_model.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ترتيب خطوات المعالج (يطابق Figma): الأخيرة هي الفرع ثم التأكيد.
enum RegisterStep { personal, source, gender, age, institution, branch }

enum RegisterStatus {
  loading,
  ready,
  loadFailed,
  submitting,
  submitFailed,
  submitted,
}

class RegisterData {
  const RegisterData({
    this.step = RegisterStep.personal,
    this.status = RegisterStatus.loading,
    this.schools = const [],
    this.branches = const [],
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.schoolId,
    this.termsAccepted = false,
    this.knowAboutApp,
    this.gender,
    this.age = RegisterCubit.defaultAge,
    this.institutionType,
    this.branchId,
  });

  final RegisterStep step;
  final RegisterStatus status;
  final List<SchoolModel> schools;
  final List<BranchModel> branches;
  final String firstName;
  final String lastName;
  final String email;
  final int? schoolId;
  final bool termsAccepted;
  final int? knowAboutApp;
  final int? gender;
  final int age;

  /// نوع المؤسسة (1 مدرسة، 2 معهد). لا يُرسل إلى users/edit حاليًا.
  /// TODO: تأكد من استخدامه (لا يوجد له حقل في users/edit).
  final int? institutionType;
  final int? branchId;

  /// مرحلة شريط التقدم: 0 = لا يظهر (الخطوتان الأوليان).
  int get stage => switch (step) {
    RegisterStep.gender || RegisterStep.age => 1,
    RegisterStep.institution => 2,
    RegisterStep.branch => 3,
    _ => 0,
  };

  /// هل يمكن الانتقال من الخطوة الحالية؟ (التحقق من خطوة البيانات في الشاشة)
  bool get canProceed => switch (step) {
    RegisterStep.personal => true,
    RegisterStep.source => knowAboutApp != null,
    RegisterStep.gender => gender != null,
    RegisterStep.age => true,
    RegisterStep.institution => institutionType != null,
    RegisterStep.branch => branchId != null,
  };

  RegisterData copyWith({
    RegisterStep? step,
    RegisterStatus? status,
    List<SchoolModel>? schools,
    List<BranchModel>? branches,
    String? firstName,
    String? lastName,
    String? email,
    int? schoolId,
    bool? termsAccepted,
    int? knowAboutApp,
    int? gender,
    int? age,
    int? institutionType,
    int? branchId,
  }) => RegisterData(
    step: step ?? this.step,
    status: status ?? this.status,
    schools: schools ?? this.schools,
    branches: branches ?? this.branches,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    schoolId: schoolId ?? this.schoolId,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    knowAboutApp: knowAboutApp ?? this.knowAboutApp,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    institutionType: institutionType ?? this.institutionType,
    branchId: branchId ?? this.branchId,
  );
}

class RegisterCubit extends Cubit<BaseState<RegisterData>> {
  RegisterCubit(this._repository)
    : super(
        const BaseState<RegisterData>(
          stateValue: StateValue.loading,
          data: RegisterData(),
        ),
      );

  /// ⚠️ قيم تقديرية: العمر الابتدائي (26 كما في Figma) والحدّان.
  static const int defaultAge = 26;
  static const int minAge = 6;
  static const int maxAge = 99;

  final RegistrationRepository _repository;
  TermsModel? _terms;

  RegisterData get _data => state.data!;

  void _updateData(RegisterData data) =>
      emit(state.copyWith(data: data, clearErrorMessage: true));

  void _emitFailure(RegisterStatus status, String message) {
    emit(
      state.copyWith(
        stateValue: StateValue.error,
        data: _data.copyWith(status: status),
        errorMessage: message,
      ),
    );
  }

  /// يحمّل المدارس والفروع. الشروط تُحمَّل عند الطلب فقط.
  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: _data.copyWith(status: RegisterStatus.loading),
        clearErrorMessage: true,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _repository.getSchools(),
        _repository.getBranches(),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            status: RegisterStatus.ready,
            schools: results[0] as List<SchoolModel>,
            branches: results[1] as List<BranchModel>,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      _emitFailure(RegisterStatus.loadFailed, e.errorMsg);
    } catch (_) {
      if (isClosed) return;
      _emitFailure(
        RegisterStatus.loadFailed,
        ErrorCode.UNKNOWN.getLocalizedMessage(),
      );
    }
  }

  /// نص الشروط (يُخزَّن بعد أول تحميل). يعيد null عند الفشل.
  Future<TermsModel?> loadTerms() async {
    if (_terms != null) return _terms;
    try {
      _terms = await _repository.getTerms();
      return _terms;
    } catch (_) {
      return null;
    }
  }

  // ───────── الخطوة (أ): البيانات الشخصية ─────────
  void setSchool(int? id) => _updateData(_data.copyWith(schoolId: id));

  void setTermsAccepted(bool value) =>
      _updateData(_data.copyWith(termsAccepted: value));

  /// التحقق من الحقول يتم في الشاشة قبل الاستدعاء.
  void savePersonalInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    _updateData(
      _data.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
      ),
    );
    next();
  }

  // ───────── الخطوات (ب إلى و) ─────────
  void selectSource(int id) => _updateData(_data.copyWith(knowAboutApp: id));

  void selectGender(int id) => _updateData(_data.copyWith(gender: id));

  void incrementAge() {
    if (_data.age < maxAge) _updateData(_data.copyWith(age: _data.age + 1));
  }

  void decrementAge() {
    if (_data.age > minAge) _updateData(_data.copyWith(age: _data.age - 1));
  }

  void selectInstitution(int id) =>
      _updateData(_data.copyWith(institutionType: id));

  void selectBranch(int id) => _updateData(_data.copyWith(branchId: id));

  void next() {
    if (!_data.canProceed) return;
    final i = _data.step.index;
    if (i < RegisterStep.values.length - 1) {
      _updateData(_data.copyWith(step: RegisterStep.values[i + 1]));
    }
  }

  void back() {
    final i = _data.step.index;
    if (i > 0) _updateData(_data.copyWith(step: RegisterStep.values[i - 1]));
  }

  /// POST users/edit مرة واحدة في النهاية.
  Future<void> submit() async {
    if (_data.status == RegisterStatus.submitting) return;

    final s = _data;
    if (s.schoolId == null ||
        s.knowAboutApp == null ||
        s.gender == null ||
        s.branchId == null) {
      _emitFailure(RegisterStatus.submitFailed, 'يرجى إكمال جميع البيانات');
      return;
    }

    emit(
      state.copyWith(
        stateValue: StateValue.loading,
        data: s.copyWith(status: RegisterStatus.submitting),
        clearErrorMessage: true,
      ),
    );
    try {
      await _repository.completeProfile(
        firstName: s.firstName,
        lastName: s.lastName,
        email: s.email,
        schoolId: s.schoolId!,
        knowAboutApp: s.knowAboutApp!,
        gender: s.gender!,
        age: s.age,
        branchId: s.branchId!,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(status: RegisterStatus.submitted),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      _emitFailure(RegisterStatus.submitFailed, e.errorMsg);
    } catch (_) {
      if (isClosed) return;
      _emitFailure(
        RegisterStatus.submitFailed,
        ErrorCode.UNKNOWN.getLocalizedMessage(),
      );
    }
  }
}
