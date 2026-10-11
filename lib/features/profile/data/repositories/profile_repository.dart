import 'package:darb/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  Future<ProfileModel> getProfile() => _remote.getProfile();

  /// تعديل الاسم والكنية والمدرسة والجنس، ويعيد الملف الشخصي المحدّث.
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required int schoolId,
    required int gender,
  }) =>
      _remote.updateProfile(
        firstName: firstName,
        lastName: lastName,
        schoolId: schoolId,
        gender: gender,
      );
}
