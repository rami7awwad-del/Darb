import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/support/data/models/faq_model.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة الأسئلة الشائعة.
class FaqsCubit extends Cubit<BaseState<List<FaqModel>>> {
  FaqsCubit(this._repository)
      : super(const BaseState<List<FaqModel>>(stateValue: StateValue.loading));

  final SupportRepository _repository;

  Future<void> load() async {
    emit(const BaseState<List<FaqModel>>(stateValue: StateValue.loading));
    try {
      final faqs = await _repository.getFaqs();
      if (isClosed) return;
      emit(BaseState<List<FaqModel>>(stateValue: StateValue.loaded, data: faqs));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(BaseState<List<FaqModel>>(
        stateValue: StateValue.error,
        errorMessage: e.errorMsg,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(BaseState<List<FaqModel>>(
        stateValue: StateValue.error,
        errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
