import 'package:darb/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';

class LessonsRepository {
  LessonsRepository(this._remote);

  final LessonsRemoteDataSource _remote;

  /// الدرس + الفصل + التعليقات من lessions/details?id= (طلب موحّد).
  Future<LessonDetailsModel> getDetails(int lessonId) =>
      _remote.getDetails(lessonId);

  Future<void> addComment({required int lessonId, required String comment}) =>
      _remote.addComment(lessonId: lessonId, comment: comment);

  Future<void> attend(int lessonId) => _remote.attend(lessonId);
}
