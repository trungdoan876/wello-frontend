import 'package:flutter/material.dart';

class AnimatedStartButton extends StatefulWidget {
  final String text; 
  final VoidCallback? onPressed; // ✅ Cho phép null => disabled
  final bool isLoading; // ✅ Hỗ trợ trạng thái loading

  const AnimatedStartButton({
    super.key,
    required this.text,
    this.onPressed, // nullable
    this.isLoading = false,
  });

  @override
  State<AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<AnimatedStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant AnimatedStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (widget.onPressed == null || widget.isLoading) {
      _controller.stop();
      _controller.value = 1.0; // giữ stable không phóng to
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child:GestureDetector(
        onTap: isDisabled ? null : widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDisabled
                  ? [
                      const Color(0xFFE0E0E0),
                      const Color(0xFFBDBDBD),
                    ] // xám mờ
                  : const [
                      Color(0xFFF8BD17),
                      Color(0xFFF4D205),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: const Color.fromARGB(255, 236, 192, 33)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.black38 : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
