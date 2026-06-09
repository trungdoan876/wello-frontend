import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_source/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppNotification>> getNotifications(String token) async {
    final list = await remoteDataSource.getNotifications(token);
    return list.map((json) => AppNotification.fromJson(json)).toList();
  }

  @override
  Future<int> getUnreadCount(String token) async {
    return await remoteDataSource.getUnreadCount(token);
  }

  @override
  Future<bool> markAsRead(String token, int id) async {
    return await remoteDataSource.markAsRead(token, id);
  }
}
