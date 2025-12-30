import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class FavoriteTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FavoriteTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          if (isActive)
            Container(
              height: 3,
              width: context.w(0.25),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }
}
