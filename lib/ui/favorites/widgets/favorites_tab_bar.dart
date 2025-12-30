import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class FavoritesTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const FavoritesTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
      child: Row(
        children: [
          _buildTab(
            'Gợi ý thực phẩm',
            0,
            selectedIndex == 0,
            () => onTabChanged(0),
            context,
          ),
          SizedBox(width: context.w(0.15)),
          _buildTab(
            'Món ăn của tôi',
            1,
            selectedIndex == 1,
            () => onTabChanged(1),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String label,
    int index,
    bool isActive,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.h(0.02)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: context.h(0.02)),
          if (isActive)
            Container(
              height: 3,
              width: context.w(0.25),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
