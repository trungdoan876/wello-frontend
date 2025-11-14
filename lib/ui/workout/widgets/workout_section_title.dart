import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WorkoutSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const WorkoutSectionTitle({
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
          title.toUpperCase(),
          style: GoogleFonts.beVietnamPro(
            fontSize: context.sp(3.1), // ~14px
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.8,
            height: 1.3,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: context.h(0.01)), // ~8px
          Text(
            subtitle!,
            style: GoogleFonts.beVietnamPro(
              fontSize: context.sp(3.2), // ~13px
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}