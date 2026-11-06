import 'package:darb/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';

class QuizRepository {
  QuizRepository(this._remote);

  final QuizRemoteDataSource _remote;

  Future<List<QuizListItem>> getMyExams() => _remote.getMyExams();
  Future<List<QuizListItem>> getMyActivities() => _remote.getMyActivities();
  Future<QuizDetails> getExam(int id) => _remote.getExam(id);
  Future<QuizScore> attend(List<int> answerIds) => _remote.attend(answerIds);
}
