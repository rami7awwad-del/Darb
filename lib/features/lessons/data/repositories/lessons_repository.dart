import 'package:darb/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';

class LessonsRepository {
  LessonsRepository(this._remote);

  final LessonsRemoteDataSource _remote;

  Future<List<CommentModel>> getComments({
    required int lessonId,
    required int page,
  }) =>
      _remote.getComments(lessonId: lessonId, page: page);

  Future<void> addComment({required int lessonId, required String comment}) =>
      _remote.addComment(lessonId: lessonId, comment: comment);

  Future<void> attend(int lessonId) => _remote.attend(lessonId);

  Future<String> getLessonFile(int lessonId) => _remote.getLessonFile(lessonId);
}
