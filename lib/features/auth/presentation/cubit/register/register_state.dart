part of 'register_cubit.dart';

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

/// حالة واحدة (وليست sealed) لأن الخطوات تتشارك البيانات المجمّعة.
/// الشاشة تستمع فقط عند تغيّر [status].
class RegisterState {
  const RegisterState({
    this.step = RegisterStep.personal,
    this.status = RegisterStatus.loading,
    this.message,
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
  final String? message;

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

  RegisterState copyWith({
    RegisterStep? step,
    RegisterStatus? status,
    String? message,
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
  }) =>
      RegisterState(
        step: step ?? this.step,
        status: status ?? this.status,
        message: message,
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
