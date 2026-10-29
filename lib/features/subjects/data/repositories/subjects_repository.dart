import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subjects/data/datasources/subjects_remote_data_source.dart';
import 'package:darb/features/subjects/data/models/subject_details_model.dart';

class SubjectsRepository {
  SubjectsRepository(this._remote);

  final SubjectsRemoteDataSource _remote;

  Future<List<SubjectModel>> getAll() => _remote.getAll();

  Future<SubjectDetailsModel> getDetails(int id) => _remote.getDetails(id);
}
