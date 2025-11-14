import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/workout_header.dart';
import 'widgets/workout_progress_card.dart';
import 'widgets/workout_section_title.dart';
import 'widgets/workout_item_card.dart';

class WorkoutPlanPage extends StatelessWidget {
  const WorkoutPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.05), // ~20px
            vertical: context.h(0.02),   // ~16px
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkoutHeader(),
              SizedBox(height: context.h(0.02)), // ~20px

              const WorkoutProgressCard(
                progress: 0.5,
                completed: 5,
                total: 10,
              ),
              SizedBox(height: context.h(0.038)), // ~30px

              // Section 1
              const WorkoutSectionTitle(
                title: "BÀI TẬP ĐƯỢC ĐỀ XUẤT DÀNH CHO BẠN HÔM NAY!",
              ),
              SizedBox(height: context.h(0.015)), // ~12px
              const WorkoutItemCard(
                imagePath: 'assets/images/wello.png',
                title: 'Pilate với Essential Kit',
                subtitle: '28 phút',
              ),
              SizedBox(height: context.h(0.038)), // ~30px

              // Section 2
              const WorkoutSectionTitle(
                title: "KHÁM PHÁ NHIỀU BÀI TẬP KHÁC",
                subtitle: "Đập tan sự nhàm chán bằng các kiểu tập luyện mới lạ.",
              ),
              SizedBox(height: context.h(0.018)), // ~15px
              const WorkoutItemCard(
                imagePath: 'assets/images/wello.png',
                title: 'Yoga với ghế',
                subtitle: '10 bài tập',
              ),
              SizedBox(height: context.h(0.015)), // ~12px
              const WorkoutItemCard(
                imagePath: 'assets/images/wello.png',
                title: 'Gym tại nhà',
                subtitle: '28 bài tập',
              ),

              // Thêm bottom padding để không bị che bởi thanh điều hướng
              SizedBox(height: context.h(0.02)),
            ],
          ),
        ),
      ),
    );
  }
}