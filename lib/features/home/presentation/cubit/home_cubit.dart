import 'dart:async';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/models/search_result_model.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Possible values for the search status.
enum SearchStatus { idle, loading, ready, failure }

/// State data for the home.
class HomeData {
  const HomeData({
    this.profile,
    this.home,
    this.query = '',
    this.searchStatus = SearchStatus.idle,
    this.searchResult = const SearchResultModel(),
    this.searchMessage,
  });

  final ProfileModel? profile;
  final HomeDataModel? home;
  final String query;
  final SearchStatus searchStatus;
  final SearchResultModel searchResult;
  final String? searchMessage;

  bool get isSearching => query.isNotEmpty;

  /// Returns a copy with the given fields replaced.
  HomeData copyWith({
    ProfileModel? profile,
    HomeDataModel? home,
    String? query,
    SearchStatus? searchStatus,
    SearchResultModel? searchResult,
    String? searchMessage,
    bool clearSearchMessage = false,
  }) => HomeData(
    profile: profile ?? this.profile,
    home: home ?? this.home,
    query: query ?? this.query,
    searchStatus: searchStatus ?? this.searchStatus,
    searchResult: searchResult ?? this.searchResult,
    searchMessage: clearSearchMessage
        ? null
        : searchMessage ?? this.searchMessage,
  );
}

/// Cubit that manages the home state.
class HomeCubit extends Cubit<BaseState<HomeData>> {
  HomeCubit(this._home, this._profile)
    : super(
        const BaseState<HomeData>(
          stateValue: StateValue.loading,
          data: HomeData(),
        ),
      );

  final HomeRepository _home;
  final ProfileRepository _profile;
  Timer? _debounce;

  HomeData get _data => state.data!;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true),
      );
    }
    try {
      final results = await Future.wait<Object>([
        _profile.getProfile(),
        _home.getHome(),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            profile: results[0] as ProfileModel,
            home: results[1] as HomeDataModel,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      _onLoadError(e.errorMsg);
    } catch (_) {
      _onLoadError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles load error.
  void _onLoadError(String message) {
    if (isClosed) return;
    if (_data.home != null && _data.profile != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  /// Handles search changed.
  void onSearchChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();

    if (query.isEmpty) {
      emit(
        state.copyWith(
          data: _data.copyWith(
            query: '',
            searchStatus: SearchStatus.idle,
            searchResult: const SearchResultModel(),
            clearSearchMessage: true,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        data: _data.copyWith(
          query: query,
          searchStatus: SearchStatus.loading,
          clearSearchMessage: true,
        ),
      ),
    );
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final result = await _home.search(query);
      if (isClosed || query != _data.query) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            searchStatus: SearchStatus.ready,
            searchResult: result,
            clearSearchMessage: true,
          ),
        ),
      );
    } on RemoteExceptions catch (e) {
      if (isClosed || query != _data.query) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            searchStatus: SearchStatus.failure,
            searchMessage: e.errorMsg,
          ),
        ),
      );
    } catch (_) {
      if (isClosed || query != _data.query) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            searchStatus: SearchStatus.failure,
            searchMessage: ErrorCode.UNKNOWN.getLocalizedMessage(),
          ),
        ),
      );
    }
  }

  /// Updates profile.
  void updateProfile(ProfileModel profile) {
    if (isClosed) return;
    emit(state.copyWith(data: _data.copyWith(profile: profile)));
  }

  /// Stops background work before the cubit closes.
  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
