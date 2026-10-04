
import 'package:darb/features/auth/data/datasources/registration_remote_data_source.dart';
import 'package:darb/features/auth/data/models/branch_model.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';

/// إكمال بيانات المستخدم الجديد: القوائم، الشروط، وحفظ البيانات.
class RegistrationRepository {
  RegistrationRepository(this._remote);

  final RegistrationRemoteDataSource _remote;

  Future<List<SchoolModel>> getSchools() => _remote.getSchools();

  Future<List<BranchModel>> getBranches() => _remote.getBranches();

  Future<TermsModel> getTerms() => _remote.getTerms();

  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    required String email,
    required int schoolId,
    required int knowAboutApp,
    required int gender,
    required int age,
    required int branchId,
  }) =>
      _remote.completeProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        schoolId: schoolId,
        knowAboutApp: knowAboutApp,
        gender: gender,
        age: age,
        branchId: branchId,
      );
}
