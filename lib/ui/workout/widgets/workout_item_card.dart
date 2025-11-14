// widgets/workout_item_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WorkoutItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const WorkoutItemCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(0.01)), // ~8px
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.03), // ~12px
          vertical: context.h(0.02),  // ~20px
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 213, 226, 254),
          borderRadius: BorderRadius.circular(context.w(0.04)), // ~16px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: context.w(0.03),
              offset: Offset(0, context.h(0.005)),
            ),
          ],
        ),
        child: Row(
          children: [
            // === Hình ảnh ===
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.w(0.03)), // ~12px
                border: Border.all(
                  color: const Color.fromARGB(255, 202, 201, 201),
                  width: context.w(0.003), // ~1.5px
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: context.w(0.02),
                    offset: Offset(0, context.h(0.005)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.w(0.03)),
                child: Image.asset(
                  imagePath,
                  width: context.w(0.22), // ~90px
                  height: context.h(0.085), // ~70px
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: context.w(0.03)), // ~12px

            // === Tiêu đề + phụ đề ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: context.sp(3.8), // ~15px
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: context.h(0.005)), // ~4px
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: context.sp(3.6), // ~14px
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: context.w(0.01)), // khoảng cách trước icon

            // === Nút mũi tên ===
            CircleAvatar(
              backgroundColor: const Color(0xFF83A8E1),
              radius: context.w(0.065), // ~26px
              child: Icon(
                Icons.arrow_outward_rounded,
                size: context.w(0.06), // ~24px
                color: Colors.white,
                weight: 600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}