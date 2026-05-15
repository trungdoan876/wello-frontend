import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CenteredBottomNavItem {
  final IconData icon;
  final String label;
  const CenteredBottomNavItem({required this.icon, required this.label});
}

class CenteredBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CenteredBottomNavItem> items;

  const CenteredBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double itemWidth = width / items.length;
    
    return Container(
      height: 110,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Nền thanh điều hướng với vết lõm (Notch) cao cấp
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: currentIndex.toDouble()),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(width, 80),
                painter: _NavPainter(
                  animatedIndex: value,
                  itemWidth: itemWidth,
                ),
              );
            },
          ),
          // Các nút chức năng
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = currentIndex == index;
                  return _buildNavItem(index, isSelected);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 80,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, isSelected ? -35 : 0, 0),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: isSelected ? 1.3 : 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFFE043), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFA500).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            // Lớp hào quang (Glow)
                            BoxShadow(
                              color: const Color(0xFFFFE043).withOpacity(0.3),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                    border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
                  ),
                  child: Icon(
                    items[index].icon,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavPainter extends CustomPainter {
  final double animatedIndex;
  final double itemWidth;

  _NavPainter({
    required this.animatedIndex,
    required this.itemWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double notchWidth = 100;
    final double notchHeight = 38;
    final double centerX = (itemWidth * animatedIndex) + (itemWidth / 2);

    path.moveTo(0, 30);
    path.quadraticBezierTo(0, 0, 30, 0);
    
    path.lineTo(centerX - notchWidth / 2 - 25, 0);
    
    // Notch mượt mà hơn với đường cong sâu hơn
    path.cubicTo(
      centerX - notchWidth / 2, 0,
      centerX - notchWidth / 3, notchHeight,
      centerX, notchHeight,
    );
    path.cubicTo(
      centerX + notchWidth / 3, notchHeight,
      centerX + notchWidth / 2, 0,
      centerX + notchWidth / 2 + 25, 0,
    );
    
    path.lineTo(size.width - 30, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Shadow cho thanh menu
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 15, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex;
  }
}

// Using CurvedNavigationBar for the bottom bar items.
