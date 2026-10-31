import 'package:flutter_bloc/flutter_bloc.dart';

/// اختيارات المستخدم أثناء الاختبار: questionId → answerId.
class QuizCubit extends Cubit<Map<int, int>> {
  QuizCubit() : super(const {});

  void select(int questionId, int answerId) =>
      emit({...state, questionId: answerId});
}
