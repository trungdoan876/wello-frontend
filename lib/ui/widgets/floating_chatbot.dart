import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/repositories/chat_repository.dart';
import 'package:wello_frontend/ui/widgets/barcode_result_screen.dart';
import 'package:wello_frontend/ui/widgets/food_image_analyzer_screen.dart';

class FloatingChatbot extends StatefulWidget {
  const FloatingChatbot({Key? key}) : super(key: key);

  @override
  State<FloatingChatbot> createState() => _FloatingChatbotState();
}

class _FloatingChatbotState extends State<FloatingChatbot> with TickerProviderStateMixin {
  bool _isOpen = false;
  bool _isTyping = false;
  final List<_BotMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  Offset _position = const Offset(16, 80); // Default to top-left of the screen
  final ChatRepository _chatRepo = ChatRepository();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initial welcome messages
    _messages.add(
      _BotMessage(
        text: "Xin chào! Mình là trợ lý Wello AI. 🌟 Mình có thể giúp gì cho bạn hôm nay?",
        isBot: true,
        time: _formatTime(DateTime.now()),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _BotMessage(
          text: text,
          isBot: false,
          time: _formatTime(DateTime.now()),
        ),
      );
      _textController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    String botReply = "";

    try {
      final creds = await AuthHelper.getCredentials();
      if (creds != null) {
        final resp = await _chatRepo.sendMessageToChatbot(
          message: text,
          token: creds.token,
        );
        final data = resp['data'];
        if (data is Map) {
          botReply = data['reply']?.toString() ?? "Mình không nhận được phản hồi từ máy chủ.";
        } else {
          botReply = "Đã xảy ra lỗi khi tải câu trả lời.";
        }
      } else {
        botReply = "Bạn cần đăng nhập để trò chuyện cùng trợ lý Wello.";
      }
    } catch (e) {
      debugPrint('[FloatingChatbot] Error calling chatbox API: $e');
      botReply = _getAIResponse(text);
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(
          _BotMessage(
            text: botReply,
            isBot: true,
            time: _formatTime(DateTime.now()),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  String _getAIResponse(String query) {
    query = query.toLowerCase();
    if (query.contains("chạy") || query.contains("chạy bộ") || query.contains("run")) {
      return "Chạy bộ rất tốt cho tim mạch! Để bắt đầu, bạn nên khởi động kỹ 5 phút, duy trì tốc độ vừa phải và chú ý tiếp đất bằng giữa bàn chân để tránh chấn thương nhé. 🏃‍♂️ Bạn có muốn lập lịch chạy hôm nay không?";
    } else if (query.contains("ăn") || query.contains("dinh dưỡng") || query.contains("calo") || query.contains("meal")) {
      return "Một chế độ ăn cân bằng cần đủ 4 nhóm chất: tinh bột tốt, chất đạm, chất béo lành mạnh và chất xơ. Hãy ưu tiên uống đủ nước trước mỗi bữa ăn 30 phút để hỗ trợ tiêu hóa nhé! 🥗";
    } else if (query.contains("ngủ") || query.contains("sleep") || query.contains("mệt")) {
      return "Giấc ngủ sâu từ 7-8 tiếng là chìa khóa để hồi phục năng lượng. Bạn nên tránh sử dụng điện thoại 30 phút trước khi ngủ và giữ phòng mát mẻ nhé. Chúc bạn có một giấc ngủ ngon! 🌙";
    } else if (query.contains("nước") || query.contains("uống")) {
      return "Uống đủ nước giúp thanh lọc cơ thể và tăng năng lượng. Bạn nên uống khoảng 1.5 - 2 lít nước mỗi ngày. Đừng đợi đến khi khát mới uống nha! 💧";
    } else if (query.contains("hello") || query.contains("chào") || query.contains("hi")) {
      return "Chào bạn! Chúc bạn một ngày mới ngập tràn năng lượng và luôn duy trì lối sống lành mạnh cùng Wello! Bạn cần mình tư vấn điều gì hôm nay? 😊";
    }
    return "Cảm ơn bạn đã chia sẻ! Trợ lý Wello AI ghi nhận ý kiến của bạn. Để duy trì sức khỏe tốt nhất, hãy thường xuyên theo dõi số bước chân, lượng nước uống và giấc ngủ trên ứng dụng Wello nhé! 🍀";
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final barcode = result.rawContent;
        
        final aiMessage = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BarcodeResultScreen(barcode: barcode)),
        );

        if (aiMessage != null && aiMessage is String) {
          _textController.text = aiMessage;
          _sendMessage();
        }
      }
    } catch (e) {
      debugPrint('[FloatingChatbot] Error scanning barcode: $e');
      setState(() {
        _messages.add(
          _BotMessage(
            text: 'Đã xảy ra lỗi khi quét mã vạch. Vui lòng thử lại sau nhé!',
            isBot: true,
            time: _formatTime(DateTime.now()),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Future<void> _takeFoodPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source, 
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        final aiMessage = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodImageAnalyzerScreen(imageFile: File(image.path))),
        );

        if (aiMessage != null && aiMessage is String) {
          _textController.text = aiMessage;
          _sendMessage();
        }
      }
    } catch (e) {
      debugPrint('[FloatingChatbot] Error picking image: $e');
      setState(() {
        _messages.add(
          _BotMessage(
            text: 'Đã xảy ra lỗi khi mở camera. Vui lòng thử lại sau nhé!',
            isBot: true,
            time: _formatTime(DateTime.now()),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double chatWidth = size.width > 400 ? 360 : size.width - 32;
    const double chatHeight = 480;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;

        return Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            // 1. Chat Box Popup (Overlay card) - rendered below the FAB
            if (_isOpen)
              _buildChatBox(size, availableHeight, chatWidth, chatHeight)
            else
              const SizedBox.shrink(key: ValueKey('empty_chatbox')),

            // 2. Draggable Floating Action Button - rendered on top, state fully preserved
            Positioned(
              key: const ValueKey('wello_fab'),
              left: _position.dx,
              top: _position.dy.clamp(80.0, availableHeight - 56.0 - 16.0),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double newX = _position.dx + details.delta.dx;
                    double newY = _position.dy + details.delta.dy;

                    // Keep inside screen boundaries: 16px margins, 80px top (app bar), 100px bottom (bottom nav)
                    newX = newX.clamp(16.0, size.width - 56.0 - 16.0);
                    newY = newY.clamp(80.0, availableHeight - 56.0 - 16.0);

                    _position = Offset(newX, newY);
                  });
                },
                onTap: _toggleChat,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing glow ring (only when closed to attract attention)
                    if (!_isOpen)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 58 + (_pulseController.value * 16),
                            height: 58 + (_pulseController.value * 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFB72B).withOpacity(0.35 * (1 - _pulseController.value)),
                            ),
                          );
                        },
                      ),
                    // Main button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD26A),
                            Color(0xFFFFB72B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB72B).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          firstChild: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          secondChild: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF2D2D2D),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
               .fadeIn(delay: 500.ms, duration: 400.ms)
               .scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatBox(Size screenSize, double availableHeight, double chatWidth, double baseChatHeight) {
    double? left;
    double? right;
    double? top;
    double? bottom;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double keyboardInset = (screenSize.height - availableHeight < 50.0) ? keyboardHeight : 0.0;
    final double usableHeight = availableHeight - keyboardInset;

    // Dynamically reduce height if keyboard is visible to ensure it fits in remaining space
    final double chatHeight = usableHeight < baseChatHeight + 120.0
        ? (usableHeight - 120.0).clamp(240.0, baseChatHeight)
        : baseChatHeight;

    final bubbleCenterX = _position.dx + 28;
    final bubbleCenterY = _position.dy + 28;

    // Horizontal placement: align with bubble or clamp to screen
    if (bubbleCenterX < screenSize.width / 2) {
      left = _position.dx.clamp(16.0, screenSize.width - chatWidth - 16.0);
    } else {
      right = (screenSize.width - _position.dx - 56).clamp(16.0, screenSize.width - chatWidth - 16.0);
    }

    // Vertical placement: place below or above the bubble
    if (bubbleCenterY < usableHeight / 2) {
      top = _position.dy + 70;
      if (top + chatHeight > usableHeight - 16.0) {
        top = null;
        bottom = keyboardInset + 16.0;
      }
    } else {
      bottom = (usableHeight - _position.dy).clamp(76.0, usableHeight - chatHeight - 16.0);
      bottom = bottom + keyboardInset;
      if (bottom < keyboardInset + 16.0) {
        bottom = keyboardInset + 16.0;
      }
    }

    // Dynamic origin for scale transition
    Alignment animationAlignment;
    if (top != null) {
      animationAlignment = left != null ? Alignment.topLeft : Alignment.topRight;
    } else {
      animationAlignment = left != null ? Alignment.bottomLeft : Alignment.bottomRight;
    }

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: chatWidth,
          height: chatHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: _buildMessageList(),
                    ),
                    if (_isTyping) _buildTypingIndicator(),
                    _buildInputBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate()
       .scale(alignment: animationAlignment, duration: 250.ms, curve: Curves.easeOutBack)
       .fadeIn(duration: 200.ms),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // AI Logo avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Wello Assistant",
                  style: GoogleFonts.baloo2(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                    height: 1.2,
                  ),
                ),
                Text(
                  "Trợ lý sức khỏe 24/7",
                  style: GoogleFonts.baloo2(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleChat,
            icon: const Icon(Icons.remove_rounded, color: Colors.grey),
            splashRadius: 20,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/organe_run.gif",
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ).animate()
                 .fadeIn(duration: 400.ms)
                 .scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 6),
                Text(
                  "Wello AI Health Coach",
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB72B),
                  ),
                ),
                Text(
                  "Cùng bạn sống khỏe mỗi ngày! 🍊",
                  style: GoogleFonts.baloo2(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.black12),
                ),
              ],
            ),
          );
        }
        final msg = _messages[index - 1];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(_BotMessage msg) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: msg.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                gradient: msg.isBot
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFFD26A), Color(0xFFFFB72B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: msg.isBot ? const Color(0xFFF0F2F5) : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isBot ? 4 : 16),
                  bottomRight: Radius.circular(msg.isBot ? 16 : 4),
                ),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.baloo2(
                  fontSize: 13.5,
                  color: msg.isBot ? const Color(0xFF2D2D2D) : const Color(0xFF1A1A1A),
                  fontWeight: msg.isBot ? FontWeight.normal : FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0, duration: 200.ms),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                msg.time,
                style: GoogleFonts.baloo2(
                  fontSize: 9.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(
                  duration: 400.ms,
                  delay: (index * 150).ms,
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.2, 1.2),
                );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chọn ảnh món ăn',
                style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Chụp ảnh',
                    color: const Color(0xFF34D399),
                    onTap: () {
                      Navigator.pop(context);
                      _takeFoodPhoto(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Thư viện',
                    color: const Color(0xFF60A5FA),
                    onTap: () {
                      Navigator.pop(context);
                      _takeFoodPhoto(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _scanBarcode,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 22,
                  color: Color(0xFF7D7A7D),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 22,
                  color: Color(0xFF7D7A7D),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 3,
                minLines: 1,
                style: GoogleFonts.baloo2(
                  fontSize: 13.5,
                  color: const Color(0xFF2D2D2D),
                ),
                decoration: const InputDecoration(
                  hintText: 'Nhập câu hỏi cho Wello...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB72B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotMessage {
  final String text;
  final bool isBot;
  final String time;

  const _BotMessage({
    required this.text,
    required this.isBot,
    required this.time,
  });
}
