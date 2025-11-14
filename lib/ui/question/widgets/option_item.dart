import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class OptionItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionItem({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: context.h(0.023),  // ~20px
          horizontal: context.w(0.05), // ~20px
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.w(0.04)), // ~16px
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7BAAF7)
                : Colors.grey.shade300,
            width: context.w(0.005), // ~2px
          ),
          color: isSelected
              ? const Color(0xFFE9F0FF)
              : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7BAAF7).withOpacity(0.2),
                    blurRadius: context.w(0.03),
                    offset: Offset(0, context.h(0.005)),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.beVietnamPro(
            fontSize: context.sp(4.2), // ~16px
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2E6CF6)
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}