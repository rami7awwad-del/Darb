part of 'complete_account_cubit.dart';

enum SchoolsStatus { loading, ready, failure }

enum SubmitStatus { idle, submitting, success, failure }

/// حالة واحدة: تحميل المدارس وقيم النموذج والإرسال تتغيّر معًا.
class CompleteAccountState {
  const CompleteAccountState({
    this.schoolsStatus = SchoolsStatus.loading,
    this.submitStatus = SubmitStatus.idle,
    this.schools = const [],
    this.firstName = '',
    this.lastName = '',
    this.schoolId,
    this.gender,
    this.schoolsMessage,
    this.message,
    this.result,
  });

  final SchoolsStatus schoolsStatus;
  final SubmitStatus submitStatus;
  final List<SchoolModel> schools;

  final String firstName;
  final String lastName;
  final int? schoolId;

  /// 0 أنثى، 1 ذكر.
  final int? gender;

  /// رسالة فشل تحميل المدارس.
  final String? schoolsMessage;

  /// رسالة فشل الإرسال (تُمسح عند أي تعديل لاحق).
  final String? message;

  /// الملف الشخصي المحدّث بعد نجاح الإرسال.
  final ProfileModel? result;

  /// كل الحقول إلزامية، ولا يُرسل طلب ثانٍ أثناء الإرسال.
  bool get canSubmit =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      schoolId != null &&
      gender != null &&
      submitStatus != SubmitStatus.submitting;

  CompleteAccountState copyWith({
    SchoolsStatus? schoolsStatus,
    SubmitStatus? submitStatus,
    List<SchoolModel>? schools,
    String? firstName,
    String? lastName,
    int? schoolId,
    int? gender,
    String? schoolsMessage,
    String? message,
    ProfileModel? result,
  }) =>
      CompleteAccountState(
        schoolsStatus: schoolsStatus ?? this.schoolsStatus,
        submitStatus: submitStatus ?? this.submitStatus,
        schools: schools ?? this.schools,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        schoolId: schoolId ?? this.schoolId,
        gender: gender ?? this.gender,
        schoolsMessage: schoolsMessage ?? this.schoolsMessage,
        message: message,
        result: result ?? this.result,
      );
}
