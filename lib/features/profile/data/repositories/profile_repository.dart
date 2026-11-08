import 'package:darb/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';

/// Repository that gives the cubits access to the profile data.
class ProfileRepository {
  ProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  Future<ProfileModel> getProfile() => _remote.getProfile();

  /// Updates profile.
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required int schoolId,
    int? gender,
  }) =>
      _remote.updateProfile(
        firstName: firstName,
        lastName: lastName,
        schoolId: schoolId,
        gender: gender,
      );
}
