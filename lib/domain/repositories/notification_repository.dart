import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String token);
  Future<int> getUnreadCount(String token);
  Future<bool> markAsRead(String token, int id);
}
