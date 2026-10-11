

import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/models/search_result_model.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';

enum HomeStatus { loading, ready, failure }

enum SearchStatus { idle, loading, ready, failure }

/// حالة واحدة تجمع تحميل الرئيسية وحالة البحث (يعملان معًا).
class HomeState {
  const HomeState({
    this.status = HomeStatus.loading,
    this.message,
    this.profile,
    this.home,
    this.query = '',
    this.searchStatus = SearchStatus.idle,
    this.searchResult = const SearchResultModel(),
    this.searchMessage,
  });

  final HomeStatus status;
  final String? message;
  final ProfileModel? profile;
  final HomeDataModel? home;

  final String query;
  final SearchStatus searchStatus;
  final SearchResultModel searchResult;
  final String? searchMessage;

  bool get isSearching => query.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    String? message,
    ProfileModel? profile,
    HomeDataModel? home,
    String? query,
    SearchStatus? searchStatus,
    SearchResultModel? searchResult,
    String? searchMessage,
  }) =>
      HomeState(
        status: status ?? this.status,
        message: message,
        profile: profile ?? this.profile,
        home: home ?? this.home,
        query: query ?? this.query,
        searchStatus: searchStatus ?? this.searchStatus,
        searchResult: searchResult ?? this.searchResult,
        searchMessage: searchMessage,
      );
}
