import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/notification_provider.dart';
import '../../domain/entities/app_notification.dart';

class NotificationListBottomSheet extends StatefulWidget {
  const NotificationListBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationListBottomSheet(),
    );
  }

  @override
  State<NotificationListBottomSheet> createState() => _NotificationListBottomSheetState();
}

class _NotificationListBottomSheetState extends State<NotificationListBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Tải thông báo khi mở sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    const Color primaryYellow = Color(0xFFEBCF23);
    const Color darkBlue = Color(0xFF1E3F48);

    return Container(
      height: screenHeight * 0.75 + keyboardHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          // Drag handle indicator
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hộp thư thông báo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                if (provider.notifications.any((n) => !n.isRead))
                  TextButton.icon(
                    onPressed: () => provider.markAllAsRead(),
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: primaryYellow),
                    label: Text(
                      'Đọc tất cả',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryYellow,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: const Color(0xFFFFFDF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // List content
          Expanded(
            child: provider.isLoading && provider.notifications.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
                    ),
                  )
                : provider.notifications.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        color: primaryYellow,
                        onRefresh: () => provider.loadNotifications(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            final notification = provider.notifications[index];
                            return _buildNotificationCard(context, notification, provider);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFDF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: Color(0xFFEBCF23),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hộp thư trống',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3F48),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Bạn chưa nhận được thông báo nào từ hệ thống hoặc quản trị viên.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    NotificationProvider provider,
  ) {
    const Color primaryYellow = Color(0xFFEBCF23);
    const Color darkBlue = Color(0xFF1E3F48);

    // Determine icon based on keywords
    IconData iconData = Icons.notifications_rounded;
    Color iconBgColor = const Color(0xFFFFFBE6);
    Color iconColor = primaryYellow;

    final lowerTitle = notification.title.toLowerCase();
    final lowerMsg = notification.message.toLowerCase();

    if (lowerTitle.contains('nước') || lowerMsg.contains('nước') || lowerMsg.contains('uống')) {
      iconData = Icons.local_drink_rounded;
      iconBgColor = const Color(0xFFE6F7FF);
      iconColor = const Color(0xFF1890FF);
    } else if (lowerTitle.contains('tập') || lowerMsg.contains('tập') || lowerMsg.contains('chạy')) {
      iconData = Icons.directions_run_rounded;
      iconBgColor = const Color(0xFFF9F0FF);
      iconColor = const Color(0xFF722ED1);
    } else if (lowerTitle.contains('ăn') || lowerMsg.contains('calo') || lowerMsg.contains('bữa')) {
      iconData = Icons.restaurant_rounded;
      iconBgColor = const Color(0xFFFFF0F6);
      iconColor = const Color(0xFFEB2F96);
    } else if (lowerTitle.contains('ngủ') || lowerMsg.contains('ngủ')) {
      iconData = Icons.bedtime_rounded;
      iconBgColor = const Color(0xFFF0F5FF);
      iconColor = const Color(0xFF2F54EB);
    } else if (lowerTitle.contains('huy hiệu') || lowerMsg.contains('huy hiệu') || lowerTitle.contains('streak')) {
      iconData = Icons.emoji_events_rounded;
      iconBgColor = const Color(0xFFFCFFE6);
      iconColor = const Color(0xFFA0D911);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: notification.isRead ? Colors.grey.shade100 : primaryYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: notification.isRead ? Colors.white : const Color(0xFFFFFDF3),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon block
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),

              // Text content block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 6),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primaryYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: notification.isRead ? Colors.grey.shade600 : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
