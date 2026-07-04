import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wello_frontend/domain/entities/app_notification.dart';
import 'package:wello_frontend/domain/repositories/notification_repository.dart';
import 'package:wello_frontend/domain/providers/notification_provider.dart';

class MockNotificationRepository implements NotificationRepository {
  List<AppNotification> mockNotifications = [];
  int mockUnreadCount = 0;
  bool shouldThrow = false;
  List<int> markedReadIds = [];

  @override
  Future<List<AppNotification>> getNotifications(String token) async {
    if (shouldThrow) throw Exception('Get notifications failed');
    return mockNotifications;
  }

  @override
  Future<int> getUnreadCount(String token) async {
    if (shouldThrow) throw Exception('Get unread count failed');
    return mockUnreadCount;
  }

  @override
  Future<bool> markAsRead(String token, int id) async {
    markedReadIds.add(id);
    return true;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'fake_token',
      'user_id': 99,
    });
  });

  group('NotificationProvider Tests', () {
    late MockNotificationRepository mockRepo;
    late NotificationProvider provider;

    setUp(() {
      mockRepo = MockNotificationRepository();
      provider = NotificationProvider(repository: mockRepo);
    });

    test('loadNotifications should populate notifications and unreadCount on success', () async {
      mockRepo.mockNotifications = [
        AppNotification(
          id: 1,
          title: 'Notif 1',
          message: 'Message 1',
          isRead: false,
          createdAt: DateTime(2026, 6, 10),
        ),
        AppNotification(
          id: 2,
          title: 'Notif 2',
          message: 'Message 2',
          isRead: true,
          createdAt: DateTime(2026, 6, 10),
        ),
      ];
      mockRepo.mockUnreadCount = 1;

      expect(provider.isLoading, isFalse);
      expect(provider.notifications, isEmpty);

      final future = provider.loadNotifications();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.notifications.length, 2);
      expect(provider.unreadCount, 1);
      expect(provider.errorMessage, isNull);
    });

    test('markAsRead should update local state and call repository', () async {
      final notification = AppNotification(
        id: 10,
        title: 'Unread Notification',
        message: 'Info',
        isRead: false,
        createdAt: DateTime(2026, 6, 10),
      );
      mockRepo.mockNotifications = [notification];
      mockRepo.mockUnreadCount = 1;

      await provider.loadNotifications();

      expect(provider.notifications[0].isRead, isFalse);
      expect(provider.unreadCount, 1);

      await provider.markAsRead(10);

      // Local state should update immediately
      expect(provider.notifications[0].isRead, isTrue);
      expect(provider.unreadCount, 0);
      expect(mockRepo.markedReadIds, contains(10));
    });
  });
}
