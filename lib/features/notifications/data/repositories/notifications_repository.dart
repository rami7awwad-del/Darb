import 'package:darb/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';

/// Repository that gives the cubits access to the notifications data.
class NotificationsRepository {
  NotificationsRepository(this._remote);

  final NotificationsRemoteDataSource _remote;

  Future<List<NotificationModel>> getNotifications({required int page}) =>
      _remote.getNotifications(page: page);
}
