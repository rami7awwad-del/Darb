import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/models/branch_model.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/features/auth/data/repositories/registration_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  /// ⚠️ قيم تقديرية: العمر الابتدائي (26 كما في Figma) والحدّان.
  static const int defaultAge = 26;
  static const int minAge = 6;
  static const int maxAge = 99;

  final RegistrationRepository _repository;
  TermsModel? _terms;

  /// يحمّل المدارس والفروع. الشروط تُحمَّل عند الطلب فقط.
  Future<void> loadInitial() async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      final results = await Future.wait<Object>([
        _repository.getSchools(),
        _repository.getBranches(),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.ready,
        schools: results[0] as List<SchoolModel>,
        branches: results[1] as List<BranchModel>,
      ));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: RegisterStatus.loadFailed, message: e.errorMsg));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.loadFailed,
        message: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
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
  void setSchool(int? id) => emit(state.copyWith(schoolId: id));

  void setTermsAccepted(bool value) =>
      emit(state.copyWith(termsAccepted: value));

  /// التحقق من الحقول يتم في الشاشة قبل الاستدعاء.
  void savePersonalInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    emit(state.copyWith(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    ));
    next();
  }

  // ───────── الخطوات (ب إلى و) ─────────
  void selectSource(int id) => emit(state.copyWith(knowAboutApp: id));

  void selectGender(int id) => emit(state.copyWith(gender: id));

  void incrementAge() {
    if (state.age < maxAge) emit(state.copyWith(age: state.age + 1));
  }

  void decrementAge() {
    if (state.age > minAge) emit(state.copyWith(age: state.age - 1));
  }

  void selectInstitution(int id) => emit(state.copyWith(institutionType: id));

  void selectBranch(int id) => emit(state.copyWith(branchId: id));

  void next() {
    if (!state.canProceed) return;
    final i = state.step.index;
    if (i < RegisterStep.values.length - 1) {
      emit(state.copyWith(step: RegisterStep.values[i + 1]));
    }
  }

  void back() {
    final i = state.step.index;
    if (i > 0) emit(state.copyWith(step: RegisterStep.values[i - 1]));
  }

  /// POST users/edit مرة واحدة في النهاية.
  Future<void> submit() async {
    if (state.status == RegisterStatus.submitting) return;

    final s = state;
    if (s.schoolId == null ||
        s.knowAboutApp == null ||
        s.gender == null ||
        s.branchId == null) {
      emit(s.copyWith(
        status: RegisterStatus.submitFailed,
        message: 'يرجى إكمال جميع البيانات',
      ));
      return;
    }

    emit(s.copyWith(status: RegisterStatus.submitting));
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
      emit(state.copyWith(status: RegisterStatus.submitted));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.submitFailed,
        message: e.errorMsg,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.submitFailed,
        message: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
