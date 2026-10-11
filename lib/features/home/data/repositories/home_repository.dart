import 'package:darb/features/home/data/datasources/home_remote_data_source.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/models/news_model.dart';
import 'package:darb/features/home/data/models/search_result_model.dart';
import 'package:darb/features/home/data/models/subject_model.dart';

class HomeRepository {
  HomeRepository(this._remote);

  final HomeRemoteDataSource _remote;

  Future<HomeDataModel> getHome() => _remote.getHome();

  Future<SearchResultModel> search(String text) => _remote.search(text);

  Future<List<NewsModel>> getAllNews() => _remote.getAllNews();

  Future<List<SubjectModel>> getAllSubjects() => _remote.getAllSubjects();
}
