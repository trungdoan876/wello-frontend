import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/data/repositories/chat_repository.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/core/services/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String? partnerAvatarUrl;

  const ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.black.withOpacity(0.04),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }
}

class _PulsingOnlineDot extends StatelessWidget {
  final Animation<double> animation;
  const _PulsingOnlineDot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 12 + (animation.value * 8),
              height: 12 + (animation.value * 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.4 * (1 - animation.value)),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  late final AnimationController _statusPulseController;
  Timer? _pollingTimer;
  bool _isSendingMessage = false;

  final ChatRepository _chatRepo = ChatRepository();
  int? _conversationId;

  @override
  void initState() {
    super.initState();
    _statusPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initConversation();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _statusPulseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initConversation() async {
    try {
      final creds = await AuthHelper.getCredentials();
      if (creds == null) return;
      final resp = await _chatRepo.createOrGetConversation(
        recipientUserId: widget.partnerId,
        token: creds.token,
      );
      final data = resp['data'];
      int? cid;
      if (data is Map) {
        final rawCid = data['conversationId'] ?? data['id'] ?? data['conversation_id'];
        if (rawCid != null) {
          if (rawCid is num) {
            cid = rawCid.toInt();
          } else {
            cid = int.tryParse(rawCid.toString());
          }
        }
        if (cid == null && data['conversation'] is Map) {
          final rawConvId = data['conversation']['id'];
          if (rawConvId != null) {
            if (rawConvId is num) {
              cid = rawConvId.toInt();
            } else {
              cid = int.tryParse(rawConvId.toString());
            }
          }
        }
      }
      if (cid != null) {
        _conversationId = cid;
        // Mark conversation as read immediately on open
        _markRead(cid, creds.token);
        await _loadMessages(cid, creds.token, creds.userId);
        _startPolling();
      }
    } catch (e) {
      debugPrint('[ChatScreen] initConversation error: $e');
    }
  }

  void _markRead(int conversationId, String token) async {
    try {
      await _chatRepo.markConversationRead(
        conversationId: conversationId,
        token: token,
      );
    } catch (e) {
      debugPrint('[ChatScreen] markConversationRead error: $e');
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_conversationId == null) return;
      final creds = await AuthHelper.getCredentials();
      if (creds == null) return;
      if (mounted) {
        _markRead(_conversationId!, creds.token);
        await _loadMessages(_conversationId!, creds.token, creds.userId);
      }
    });
  }

  Future<void> _loadMessages(
    int conversationId,
    String token,
    int myUserId,
  ) async {
    try {
      final list = await _chatRepo.getMessages(
        conversationId: conversationId,
        token: token,
      );
      final mapped = <_ChatMessage>[];
      final existingIds = _messages.map((m) => m.id).toSet();
      final bool isInitialLoad = _messages.isEmpty;
      bool hasNewIncoming = false;
      String lastIncomingText = '';

      for (final raw in list) {
        if (raw is Map) {
          final text =
              (raw['textContent'] ??
                      raw['text_content'] ??
                      raw['content'] ??
                      raw['message'] ??
                      raw['text'])
                  ?.toString();
          final rawSenderId =
              raw['senderUserId'] ??
              raw['sender_user_id'] ??
              raw['userId'] ??
              raw['user_id'];
          int? senderId;
          if (rawSenderId != null) {
            if (rawSenderId is num) {
              senderId = rawSenderId.toInt();
            } else {
              senderId = int.tryParse(rawSenderId.toString());
            }
          }
          final isMe = senderId != null ? senderId == myUserId : false;

          final dynamic rawIsRead = raw['isRead'] ?? raw['is_read'] ?? raw['seen'] ?? raw['viewed'];
          final dynamic rawReadAt = raw['readAt'] ?? raw['read_at'];

          bool isSeen = false;
          if (rawIsRead != null) {
            if (rawIsRead is bool) {
              isSeen = rawIsRead;
            } else if (rawIsRead is num) {
              isSeen = rawIsRead.toInt() == 1;
            } else if (rawIsRead is String) {
              isSeen = rawIsRead == 'true' || rawIsRead == '1';
            }
          }
          if (!isSeen && rawReadAt != null && rawReadAt.toString().toLowerCase() != 'null' && rawReadAt.toString().trim().isNotEmpty) {
            isSeen = true;
          }

          final bool isSent = true;

          DateTime? dt;
          if (raw['createdAt'] != null) {
            try {
              dt = DateTime.parse(raw['createdAt'].toString()).toLocal();
            } catch (_) {}
          }

          final id = raw['id'];
          mapped.add(
            _ChatMessage(
              id: id,
              text: text,
              isMe: isMe,
              timeLabel: _formatTimestamp(raw['createdAt']?.toString()),
              isSent: isSent,
              isSeen: isSeen,
              dateTime: dt,
            ),
          );

          if (!isInitialLoad && !isMe && id != null && !existingIds.contains(id)) {
            hasNewIncoming = true;
            lastIncomingText = text ?? 'Đã gửi một tin nhắn';
          }
        }
      }

      if (hasNewIncoming) {
        try {
          NotificationService.showLocalNotification(
            widget.partnerName,
            lastIncomingText,
          );
        } catch (e) {
          debugPrint('[ChatScreen] showLocalNotification error: $e');
        }
      }
      
      // Update messages in reversed order (newest at index 0)
      if (mounted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(mapped.reversed);
        });
      }
    } catch (e) {
      debugPrint('[ChatScreen] loadMessages error: $e');
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _isSendingMessage = true;
      _messages.insert(
        0,
        _ChatMessage(
          id: tempId,
          text: text,
          isMe: true,
          isSent: true,
          isSeen: false,
          timeLabel: _timeNow(),
          dateTime: DateTime.now(),
        ),
      );
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final creds = await AuthHelper.getCredentials();
      if (creds == null) return;

      if (_conversationId != null) {
        await _chatRepo.sendMessageToConversation(
          conversationId: _conversationId!,
          token: creds.token,
          recipientUserId: widget.partnerId,
          textContent: text,
        );
      } else {
        final resp = await _chatRepo.sendMessageToUser(
          recipientUserId: widget.partnerId,
          token: creds.token,
          textContent: text,
        );
        final data = resp['data'];
        if (data is Map) {
          final cid =
              (data['conversationId'] ?? data['conversation_id'] ?? data['id'])
                  as int?;
          if (cid != null) {
            setState(() => _conversationId = cid);
            _startPolling();
          }
        }
      }

      // Reload messages to update local list with real IDs and status
      if (_conversationId != null) {
        await _loadMessages(_conversationId!, creds.token, creds.userId);
      }
    } catch (e) {
      debugPrint('[ChatScreen] sendMessage error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return '';
    try {
      final date = DateTime.parse(ts).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: 300.ms, curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F6F9),
              Color(0xFFEAEFF5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_chat.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 88, 16, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      
                      // Check for consecutive bubbles from same sender
                      bool hasPrev = false;
                      bool hasNext = false;
                      if (index < _messages.length - 1) {
                        hasPrev = _messages[index + 1].isMe == message.isMe;
                      }
                      if (index > 0) {
                        hasNext = _messages[index - 1].isMe == message.isMe;
                      }

                      // Check for date header
                      bool showHeader = false;
                      if (index == _messages.length - 1) {
                        showHeader = true;
                      } else {
                        final prevMsg = _messages[index + 1];
                        if (message.dateTime != null && prevMsg.dateTime != null) {
                          final diff = message.dateTime!.difference(prevMsg.dateTime!);
                          if (diff.inMinutes > 15 || message.dateTime!.day != prevMsg.dateTime!.day) {
                            showHeader = true;
                          }
                        }
                      }

                      final bubble = _ChatBubble(
                        message: message,
                        hasPrev: hasPrev,
                        hasNext: hasNext,
                        partnerAvatarUrl: widget.partnerAvatarUrl,
                      );

                      if (showHeader && message.dateTime != null) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _DateHeader(dateTime: message.dateTime!),
                            bubble,
                          ],
                        );
                      }
                      return bubble;
                    },
                  ),
                ),
                _buildInputArea(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60,
              leadingWidth: 62,
              leading: Center(
                child: _HeaderActionButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
              ),
              title: Row(
                children: [
                  _buildAvatarStack(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.partnerName,
                          style: GoogleFonts.baloo2(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                        Row(
                          children: [
                            _PulsingOnlineDot(animation: _statusPulseController),
                            const SizedBox(width: 4),
                            Text(
                              'Đang hoạt động',
                              style: GoogleFonts.baloo2(
                                fontSize: 11,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                _HeaderActionButton(icon: Icons.videocam_rounded, onTap: () {}),
                const SizedBox(width: 6),
                _HeaderActionButton(
                  icon: Icons.info_outline_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image:
                  AvatarHelper.getImageProvider(widget.partnerAvatarUrl) ??
                  const AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _InputActionButton(
              icon: Icons.add_rounded,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.baloo2(
                    fontSize: 15,
                    color: const Color(0xFF2D2D2D),
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'Nhắn tin...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
              isSending: _isSendingMessage,
              hasText: _messageController.text.trim().isNotEmpty,
              onTap: _isSendingMessage ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _InputActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4A4A4A)),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isSending;
  final bool hasText;
  final VoidCallback? onTap;

  const _SendButton({
    required this.isSending,
    required this.hasText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color btnColor = isSending
        ? Colors.grey.shade300
        : (hasText ? const Color(0xFFFFB72B) : const Color(0xFFF5F6F8));
    final Color iconColor = isSending
        ? Colors.grey
        : (hasText ? const Color(0xFF2D2D2D) : Colors.grey.shade400);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: btnColor,
            shape: BoxShape.circle,
            boxShadow: hasText && !isSending
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB72B).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D2D2D)),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool hasPrev;
  final bool hasNext;
  final String? partnerAvatarUrl;

  const _ChatBubble({
    required this.message,
    required this.hasPrev,
    required this.hasNext,
    this.partnerAvatarUrl,
  });

  BorderRadius _getMeBorderRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      bottomLeft: const Radius.circular(20),
      topRight: Radius.circular(hasPrev ? 6 : 20),
      bottomRight: Radius.circular(hasNext ? 6 : 4),
    );
  }

  BorderRadius _getPartnerBorderRadius() {
    return BorderRadius.only(
      topRight: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
      topLeft: Radius.circular(hasPrev ? 6 : 20),
      bottomLeft: Radius.circular(hasNext ? 6 : 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe;

    Widget bubbleContent = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: isMe
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD26A),
                  Color(0xFFFFB72B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: _getMeBorderRadius(),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB72B).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: _getPartnerBorderRadius(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFEFEFEF),
                width: 1,
              ),
            ),
      child: Text(
        message.text ?? '',
        style: GoogleFonts.baloo2(
          fontSize: 16,
          color: const Color(0xFF2D2D2D),
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );

    Widget statusRow = Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.timeLabel,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            _buildStatusIndicator(),
          ],
        ],
      ),
    );

    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(
            top: hasPrev ? 1.5 : 8,
            bottom: hasNext ? 1.5 : 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              bubbleContent,
              statusRow,
            ],
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).moveX(begin: 15, end: 0);
    } else {
      final showAvatar = !hasNext;

      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            top: hasPrev ? 1.5 : 8,
            bottom: hasNext ? 1.5 : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAvatar)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                    image: DecorationImage(
                      image: AvatarHelper.getImageProvider(partnerAvatarUrl) ??
                          const AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bubbleContent,
                  statusRow,
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).moveX(begin: -15, end: 0);
    }
  }

  Widget _buildStatusIndicator() {
    if (message.isSeen) {
      return Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 0.8),
          image: DecorationImage(
            image: AvatarHelper.getImageProvider(partnerAvatarUrl) ??
                const AssetImage('assets/images/logo.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (message.isSent) {
      return Icon(
        Icons.check_rounded,
        size: 13,
        color: Colors.grey.shade400,
      );
    } else {
      return const SizedBox(
        width: 8,
        height: 8,
        child: CircularProgressIndicator(
          strokeWidth: 1.2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime dateTime;
  const _DateHeader({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(dateTime),
            style: GoogleFonts.baloo2(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    final hourStr = dt.hour.toString().padLeft(2, '0');
    final minStr = dt.minute.toString().padLeft(2, '0');
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Hôm nay, $hourStr:$minStr';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return 'Hôm qua, $hourStr:$minStr';
    }
    return '${dt.day}/${dt.month}/${dt.year} $hourStr:$minStr';
  }
}

class _ChatMessage {
  final dynamic id;
  final String? text;
  final bool isMe;
  final String timeLabel;
  final bool isSent;
  final bool isSeen;
  final DateTime? dateTime;

  const _ChatMessage({
    this.id,
    required this.text,
    required this.isMe,
    required this.timeLabel,
    this.isSent = true,
    this.isSeen = false,
    this.dateTime,
  });
}
