import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/features/support/data/models/info_page_type.dart';
import 'package:darb/features/support/data/repositories/support_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة نصية: سياسة الاستخدام أو سياسة الخصوصية (حسب [type]).
class InfoPageCubit extends Cubit<BaseState<TermsModel>> {
  InfoPageCubit(this._repository, {required this.type})
      : super(const BaseState<TermsModel>(stateValue: StateValue.loading));

  final SupportRepository _repository;
  final InfoPageType type;

  Future<void> load() async {
    emit(const BaseState<TermsModel>(stateValue: StateValue.loading));
    try {
      final page = await _repository.getPage(type);
      if (isClosed) return;
      emit(BaseState<TermsModel>(stateValue: StateValue.loaded, data: page));
    } on RemoteExceptions catch (e) {
      if (isClosed) return;
      emit(BaseState<TermsModel>(
        stateValue: StateValue.error,
        errorMessage: e.errorMsg,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(BaseState<TermsModel>(
        stateValue: StateValue.error,
        errorMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
