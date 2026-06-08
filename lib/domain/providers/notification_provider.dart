import 'package:flutter/material.dart';
import '../../core/utils/auth_helper.dart';
import '../../data/data_source/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationProvider({NotificationRepository? repository})
      : repository = repository ??
            NotificationRepositoryImpl(
              remoteDataSource: NotificationRemoteDataSource(),
            );

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Nạp danh sách thông báo và số lượng chưa đọc từ backend
  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      if (token == null || token.isEmpty) {
        _isLoading = false;
        return;
      }

      // Chạy song song 2 request
      final results = await Future.wait([
        repository.getNotifications(token),
        repository.getUnreadCount(token),
      ]);

      _notifications = results[0] as List<AppNotification>;
      _unreadCount = results[1] as int;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Đánh dấu một thông báo đã đọc
  Future<void> markAsRead(int notificationId) async {
    final credentials = await AuthHelper.getCredentials();
    final token = credentials?.token;

    if (token == null || token.isEmpty) return;

    // Cập nhật local lập tức (optimistic update) để tăng độ nhạy UI
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      final oldNoti = _notifications[index];
      _notifications[index] = AppNotification(
        id: oldNoti.id,
        title: oldNoti.title,
        message: oldNoti.message,
        isRead: true,
        createdAt: oldNoti.createdAt,
      );
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      notifyListeners();
    }

    try {
      await repository.markAsRead(token, notificationId);
    } catch (e) {
      print('Lỗi khi đánh dấu thông báo đã đọc trên server: $e');
      // Tải lại để đảm bảo dữ liệu khớp nếu có lỗi
      await loadNotifications();
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    final credentials = await AuthHelper.getCredentials();
    final token = credentials?.token;

    if (token == null || token.isEmpty) return;

    // Tìm các thông báo chưa đọc trước khi đánh dấu chúng
    final unreadNotis = _notifications.where((n) => !n.isRead).toList();

    if (unreadNotis.isNotEmpty) {
      // Cập nhật local trước
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          final old = _notifications[i];
          _notifications[i] = AppNotification(
            id: old.id,
            title: old.title,
            message: old.message,
            isRead: true,
            createdAt: old.createdAt,
          );
        }
      }
      _unreadCount = 0;
      notifyListeners();

      // Gửi yêu cầu cho các thông báo chưa đọc
      final List<Future> futures = [];
      for (var noti in unreadNotis) {
        futures.add(repository.markAsRead(token, noti.id));
      }
      
      try {
        await Future.wait(futures);
      } catch (e) {
        print('Lỗi khi lưu trạng thái đã đọc hàng loạt lên server: $e');
      }

      await loadNotifications();
    }
  }
}
