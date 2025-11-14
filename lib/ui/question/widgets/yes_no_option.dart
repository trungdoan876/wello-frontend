import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class YesNoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const YesNoOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = context.w(0.35); // ~150px trên màn 390px

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        padding: EdgeInsets.all(context.w(0.05)),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7BAAF7).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.w(0.04)), // ~16px
          border: Border.all(
            color: isSelected ? const Color(0xFF7BAAF7) : Colors.grey[300]!,
            width: context.w(0.007), // ~3px
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7BAAF7).withOpacity(0.2),
                    blurRadius: context.w(0.04),
                    offset: Offset(0, context.h(0.008)),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: context.w(0.02),
                    offset: Offset(0, context.h(0.004)),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.w(0.15), // ~60px
              color: isSelected ? const Color(0xFF7BAAF7) : Colors.black54,
            ),
            SizedBox(height: context.h(0.01)), // ~8px
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: context.sp(4.6), // ~18px
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF7BAAF7) : Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}