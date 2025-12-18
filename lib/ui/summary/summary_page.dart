import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/main_navigation_screen.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../../data/models/responses/survey_response_model.dart';
import '../main_navigation_screen.dart';
import 'widgets/calorie_card.dart';
import 'widgets/bmi_card.dart';
import 'widgets/section_title.dart';
import 'widgets/water_card.dart';

class SummaryPage extends StatelessWidget {
  final SurveyResponseModel survey;
  const SummaryPage({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFAE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Thống kê các chỉ số",
          style: GoogleFonts.baloo2(
            color: const Color(0xFFEBCF23),
            fontSize: context.sp(7),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.05),
          vertical: context.h(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: "Năng lượng cần nạp vào mỗi ngày",
            ),

            SizedBox(height: context.h(0.015)),
            CalorieCard(survey: survey),

            SizedBox(height: context.h(0.04)),
            SectionTitle(title: "Chỉ số cơ thể"),

            SizedBox(height: context.h(0.015)),
            BMICard(survey: survey),

            SizedBox(height: context.h(0.04)),
            SectionTitle(title: "Bạn nên uống bao nhiêu nước"),

            SizedBox(height: context.h(0.015)),
            WaterCard(survey: survey),
            SizedBox(height: context.h(0.05)),
            Center(
              child: SizedBox(
                width: context.w(0.8), // responsive theo chiều ngang
                child: AnimatedStartButton(
                  text: "Tiếp tục",
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MainNavigationScreen()),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: context.h(0.03)),
          ],
        ),
      ),
    );
  }
}
