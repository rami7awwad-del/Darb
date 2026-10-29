import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._api);

  final ApiService _api;

  /// GET notifications/get?page=1 → data: قائمة إشعارات.
  Future<List<NotificationModel>> getNotifications({required int page}) async {
    final response = await _api.getRequest(
      ApiConstants.notificationsGet,
      queryParameters: {'page': page},
    );
    try {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List;
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
