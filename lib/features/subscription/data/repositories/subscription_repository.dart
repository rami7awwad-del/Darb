import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:darb/features/subscription/data/models/package_model.dart';
import 'package:darb/features/subscription/data/models/payment_method_model.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._remote);

  final SubscriptionRemoteDataSource _remote;

  Future<List<CourseModel>> getMyCourses() => _remote.getMyCourses();
  Future<List<PaymentMethodModel>> getPaymentMethods() =>
      _remote.getPaymentMethods();
  Future<List<PackageModel>> getPackages() => _remote.getPackages();
  Future<void> subscribeWithCode(String code) =>
      _remote.subscribeWithCode(code.trim());
}
