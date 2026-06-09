import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/data/repositories/chat_repository.dart';
import 'package:wello_frontend/ui/community/chat/chat_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatRepository _chatRepo = ChatRepository();
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _error;

  int get _totalUnread => _conversations.fold(
        0,
        (sum, c) => sum + ((c['unreadCount'] as num?)?.toInt() ?? 0),
      );

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final creds = await AuthHelper.getCredentials();
      if (creds == null) throw Exception('Chưa đăng nhập');
      final list = await _chatRepo.getConversations(token: creds.token);
      if (mounted) setState(() => _conversations = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tin nhắn',
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            if (!_isLoading && _totalUnread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBCF23),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalUnread chưa đọc',
                  style: GoogleFonts.baloo2(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFEBCF23)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Không thể tải tin nhắn', style: GoogleFonts.baloo2(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadConversations,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEBCF23)),
              child: Text('Thử lại', style: GoogleFonts.baloo2(color: Colors.black)),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có tin nhắn nào',
              style: GoogleFonts.baloo2(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy ghé thăm trang cá nhân của\nbạn bè và bắt đầu trò chuyện!',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: const Color(0xFFEBCF23),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.015),
        ),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final conv = _conversations[index] as Map<String, dynamic>;
          return _ConversationTile(
            conv: conv,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    partnerId: conv['partnerUserId'] as int,
                    partnerName: conv['partnerFullName'] as String? ?? 'Người dùng',
                    partnerAvatarUrl: conv['partnerAvatarUrl'] as String?,
                  ),
                ),
              );
              _loadConversations();
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conv;
  final VoidCallback onTap;

  const _ConversationTile({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = conv['partnerFullName'] as String? ?? 'Người dùng';
    final avatarUrl = conv['partnerAvatarUrl'] as String?;
    final lastMsg = conv['lastMessagePreview'] as String?;
    final rawTime = conv['lastMessageAt'] as String?;
    final unread = (conv['unreadCount'] as num?)?.toInt() ?? 0;
    final hasUnread = unread > 0;

    String timeLabel = '';
    if (rawTime != null) {
      try {
        String tsStr = rawTime;
        if (!tsStr.contains('Z') && !tsStr.contains('+') && !RegExp(r'-\d{2}:\d{2}$').hasMatch(tsStr)) {
          if (tsStr.contains(' ') && !tsStr.contains('T')) {
            tsStr = tsStr.replaceFirst(' ', 'T');
          }
          tsStr += 'Z';
        }
        final dt = DateTime.parse(tsStr).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inDays >= 1) {
          timeLabel = '${dt.day}/${dt.month}';
        } else {
          final h = dt.hour.toString().padLeft(2, '0');
          final m = dt.minute.toString().padLeft(2, '0');
          timeLabel = '$h:$m';
        }
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Nền vàng nhạt khi có tin chưa đọc, trắng khi đã đọc
          color: hasUnread ? const Color(0xFFFFFBE6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Viền vàng nổi bật khi có tin chưa đọc
          border: hasUnread
              ? Border.all(color: const Color(0xFFEBCF23), width: 1.8)
              : Border.all(color: Colors.transparent, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? const Color(0xFFEBCF23).withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: hasUnread ? 14 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar với ring vàng nếu có tin chưa đọc
                Container(
                  padding: hasUnread ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
                  decoration: hasUnread
                      ? const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFEBCF23), Color(0xFFFFB300)],
                          ),
                        )
                      : null,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFFFF4C6),
                    backgroundImage: AvatarHelper.getImageProvider(avatarUrl),
                    child: avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                // Badge số tin chưa đọc (góc trên phải)
                if (hasUnread)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.baloo2(
                            fontSize: hasUnread ? 16 : 15,
                            fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      // Thời gian — vàng đậm khi chưa đọc
                      Text(
                        timeLabel,
                        style: GoogleFonts.baloo2(
                          fontSize: 12,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                          color: hasUnread
                              ? const Color(0xFFD4A000)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg ?? 'Bắt đầu cuộc trò chuyện',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.baloo2(
                            fontSize: 13,
                            color: hasUnread
                                ? const Color(0xFF3D3D3D)
                                : Colors.grey[500],
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                      // Chấm tròn xanh "chưa đọc" ở cuối dòng
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBCF23),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
