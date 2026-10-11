import 'dart:async';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/models/search_result_model.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/home/presentation/cubit/home_state.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._home, this._profile) : super(const HomeState());

  final HomeRepository _home;
  final ProfileRepository _profile;
  Timer? _debounce;

  /// يحمّل الملف الشخصي (الشريط العلوي) وبيانات الرئيسية معًا.
  /// [silent] = true للسحب للتحديث: لا يُظهر مؤشر التحميل الكامل.
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: HomeStatus.loading));
    try {
      final results = await Future.wait<Object>([
        _profile.getProfile(),
        _home.getHome(),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        status: HomeStatus.ready,
        profile: results[0] as ProfileModel,
        home: results[1] as HomeDataModel,
      ));
    } on RemoteExceptions catch (e) {
      _onLoadError(e.errorMsg);
    } catch (_) {
      _onLoadError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onLoadError(String message) {
    if (isClosed) return;
    // فشل تحديث صامت مع وجود بيانات سابقة: نُبقي ما هو معروض.
    if (state.home != null && state.profile != null) return;
    emit(state.copyWith(status: HomeStatus.failure, message: message));
  }

  /// بحث مع تأخير 400ms لتقليل الطلبات. النص الفارغ يعيد الرئيسية.
  void onSearchChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();

    if (query.isEmpty) {
      emit(state.copyWith(
        query: '',
        searchStatus: SearchStatus.idle,
        searchResult: const SearchResultModel(),
      ));
      return;
    }

    emit(state.copyWith(query: query, searchStatus: SearchStatus.loading));
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final result = await _home.search(query);
      // تجاهل رد قديم إن تغيّر النص أثناء الانتظار.
      if (isClosed || query != state.query) return;
      emit(state.copyWith(
        searchStatus: SearchStatus.ready,
        searchResult: result,
      ));
    } on RemoteExceptions catch (e) {
      if (isClosed || query != state.query) return;
      emit(state.copyWith(
        searchStatus: SearchStatus.failure,
        searchMessage: e.errorMsg,
      ));
    } catch (_) {
      if (isClosed || query != state.query) return;
      emit(state.copyWith(
        searchStatus: SearchStatus.failure,
        searchMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }

  /// يستبدل الملف الشخصي بعد تعديله من نافذة إكمال الحساب،
  /// فيتحدّث الشريط العلوي فورًا دون إعادة تحميل الرئيسية.
  void updateProfile(ProfileModel profile) {
    if (isClosed) return;
    emit(state.copyWith(profile: profile));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
