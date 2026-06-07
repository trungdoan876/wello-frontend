import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Premium chat screen inspired by Instagram/Telegram/ChatGPT
// Self-contained UI components, uses assets/images/bg_chat.jpg from project

class PremiumChatScreen extends StatefulWidget {
  const PremiumChatScreen({Key? key}) : super(key: key);

  @override
  State<PremiumChatScreen> createState() => _PremiumChatScreenState();
}

class _PremiumChatScreenState extends State<PremiumChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _isSending = false;
  bool _showTyping = false;

  final List<_Msg> _messages = [
    _Msg(text: 'Chào bạn', time: '13:00', isMe: false),
    _Msg(text: 'Hi', time: '13:00', isMe: true),
    _Msg(text: 'G', time: '19:36', isMe: true),
    _Msg(text: 'Chào bạn', time: '19:36', isMe: true),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isSending = true;
      _messages.insert(0, _Msg(text: text, time: _timeNow(), isMe: true));
      _controller.clear();
    });
    await Future.delayed(const Duration(milliseconds: 420));
    setState(() => _isSending = false);
    // simulate reply
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _messages.insert(
        0,
        _Msg(text: 'Mình đã thấy: "$text"', time: _timeNow(), isMe: false),
      );
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // wallpaper background
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_chat.jpg',
                fit: BoxFit.cover,
                // slightly darker so messages stand out better (increased from 0.18 to 0.3)
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // gradient dim + blur overlay for premium feel
            Positioned.fill(
              child: BackdropFilter(
                // increase blur to soften the wallpaper more (increased from 8 to 18)
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                // use a subtle dark overlay so chat bubbles contrast better (increased from 0.36 to 0.45)
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),

            // content
            Column(
              children: [
                _PremiumHeader(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (n) => false,
                            child: ListView.separated(
                              controller: _scroll,
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  _messages.length + (_showTyping ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, idx) {
                                if (_showTyping && idx == 0) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: _FloatingDate(
                                      'Typing...',
                                    ).animate().fade(duration: 450.ms),
                                  );
                                }
                                final m =
                                    _messages[idx - (_showTyping ? 1 : 0)];
                                return m.isMe
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: _UserBubble(
                                          text: m.text,
                                          time: m.time,
                                        ),
                                      ).animate().slideX(
                                        duration: 420.ms,
                                        curve: Curves.easeOut,
                                      )
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: _FriendBubble(
                                          text: m.text,
                                          time: m.time,
                                        ),
                                      ).animate().slideX(
                                        duration: 420.ms,
                                        curve: Curves.easeOut,
                                      );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _Composer(
                  controller: _controller,
                  isSending: _isSending,
                  onSend: _send,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final String time;
  final bool isMe;
  const _Msg({required this.text, required this.time, required this.isMe});
}

class _PremiumHeader extends StatefulWidget {
  final VoidCallback onBack;
  const _PremiumHeader({Key? key, required this.onBack}) : super(key: key);

  @override
  State<_PremiumHeader> createState() => _PremiumHeaderState();
}

class _PremiumHeaderState extends State<_PremiumHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // avatar with glow
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.08),
                        blurRadius: 24 * _pulse.value + 4,
                        spreadRadius: 2 * _pulse.value,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'le',
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // online animated dot
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                        CurvedAnimation(
                          parent: _pulse,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đang hoạt động gần đây',
                      style: GoogleFonts.baloo2(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _FloatingIcon(icon: Icons.call_rounded),
              const SizedBox(width: 8),
              _FloatingIcon(icon: Icons.more_horiz_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  const _FloatingIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }
}

class _FloatingDate extends StatelessWidget {
  final String text;
  const _FloatingDate(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.baloo2(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final String time;
  const _UserBubble({Key? key, required this.text, required this.time})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD26A), Color(0xFFFFC400)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.baloo2(
                  fontSize: 15,
                  color: const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.baloo2(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 14, color: Colors.black54),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}

class _FriendBubble extends StatelessWidget {
  final String text;
  final String time;
  const _FriendBubble({Key? key, required this.text, required this.time})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.baloo2(
                    fontSize: 15,
                    color: const Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.baloo2(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fade(duration: 420.ms),
        ),
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  const _Composer({
    Key? key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  }) : super(key: key);

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _btn;

  @override
  void initState() {
    super.initState();
    _btn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _btn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: Color(0xFFE68F00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhắn tin cho le...',
                            hintStyle: GoogleFonts.baloo2(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) => _btn.reverse(),
                        onTapUp: (_) => _btn.forward(),
                        onTapCancel: () => _btn.forward(),
                        onTap: widget.onSend,
                        child: ScaleTransition(
                          scale: _btn,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD26A), Color(0xFFFFC400)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: widget.isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Color(0xFF2D2D2D),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
