// ui/workout/workout_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/workout/widgets/workout_item_card.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = [
      {"image": "assets/images/wello.png", "title": "Mobility Moves", "time": "21 phút"},
      {"image": "assets/images/wello.png", "title": "Posture Care", "time": "17 phút"},
      {"image": "assets/images/wello.png", "title": "Senior Strength", "time": "28 phút"},
      {"image": "assets/images/wello.png", "title": "Gentle Arm Sculpt", "time": "20 phút"},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.06),
            vertical: context.h(0.015),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Header (căn giữa) ===
              SizedBox(height: context.h(0.01)),
              Center(
                child: Text(
                  "Yoga với ghế",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(5.8),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: context.h(0.008)),

              // "10 bài tập" → Căn trái
              Text(
                "10 bài tập",
                style: GoogleFonts.beVietnamPro(
                  fontSize: context.sp(4.2),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: context.h(0.015)), // ~28px (tăng khoảng cách)

              // === Danh sách bài tập ===
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) => SizedBox(height: context.h(0.025)), // ← Tăng khoảng cách
                  itemBuilder: (context, index) {
                    final item = workouts[index];
                    return WorkoutItemCard(
                      imagePath: item["image"]!,
                      title: item["title"]!,
                      subtitle: item["time"]!,
                      onTap: () {
                      
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}