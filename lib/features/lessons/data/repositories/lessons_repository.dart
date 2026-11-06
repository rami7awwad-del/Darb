import 'package:darb/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';

/// Repository that gives the cubits access to the lessons data.
class LessonsRepository {
  LessonsRepository(this._remote);

  final LessonsRemoteDataSource _remote;

  /// Gets details.
  Future<LessonDetailsModel> getDetails(int lessonId) =>
      _remote.getDetails(lessonId);

  /// Adds comment.
  Future<void> addComment({required int lessonId, required String comment}) =>
      _remote.addComment(lessonId: lessonId, comment: comment);

  Future<void> attend(int lessonId) => _remote.attend(lessonId);
}
