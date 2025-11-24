import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
           style: GoogleFonts.baloo2(
            color: const Color(0xFF4C494C),
            fontSize: context.sp(5),
            fontWeight: FontWeight.bold,
          ),
        ),
       
      ],
    );
  }
}
