import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  const NextButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = 'NEXT',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.06), // ~24px
        vertical: context.h(0.01),   // ~8px
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.h(0.075), // ~60px
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled
                ? const Color(0xFF7BAAF7)
                : const Color(0xFFD0D8E8),
            elevation: enabled ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.w(0.07)), // ~28px
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: enabled ? onPressed : null,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.beVietnamPro(
              fontSize: context.sp(4.2), // ~16px
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}