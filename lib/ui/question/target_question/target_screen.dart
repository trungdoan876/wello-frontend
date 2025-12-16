import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/data/models/question.dart';
import 'package:wello_frontend/ui/question/activity_question/activity_level_screen.dart';
import 'package:wello_frontend/ui/question/activity_question/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class TargetLevelScreen extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? age;
  const TargetLevelScreen({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.age,
  });

  @override
  State<TargetLevelScreen> createState() => _TargetLevelScreenState();
}

class _TargetLevelScreenState extends State<TargetLevelScreen> {
  String? _selectedLevel;

  // Mapping tạm thời cho Subtitle vì backend chưa trả về
  final Map<String, String> _subtitleMap = {
    "GAIN_WEIGHT": "Ăn nhiều hơn, tăng cơ và cân nặng",
    "LOSE_WEIGHT": "Ăn kiểm soát để giảm mỡ thừa",
    "KEEP_FIT": "Giữ cân năng ổn định , sống khỏe",
  };

  void _selectLevel(String level) {
    setState(() {
      _selectedLevel = level;
    });
    print('Selected Target Level: $level');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // ---- APP BAR ----
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + context.h(0.0)),
        child: Padding(
          padding: EdgeInsets.only(top: context.h(0.0)),
          child: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFFFFBEA),
            centerTitle: true,
            leadingWidth: context.w(0.2),
            iconTheme: IconThemeData(
              color: const Color(0xffEBCF23),
              size: context.sp(10),
            ),
            title: Text(
              "Wello",
              style: GoogleFonts.pacifico(
                fontSize: context.sp(12.0),
                color: const Color(0xffEBCF23),
              ),
            ),
          ),
        ),
      ),

      extendBodyBehindAppBar: true,

      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // ------ Background full màn hình ------
            SizedBox(
              width: size.width,
              height: size.height,
              child: Image.asset(
                'assets/images/question_bg_2.png',
                fit: BoxFit.cover,
              ),
            ),

            // ------ Nội dung chính ------
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.h(0.08)), // đẩy xuống dưới AppBar
                  // --- Câu hỏi chính ---
                  Text(
                    widget.question.question,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(8.0),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffEBCF23),
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: context.h(0.03)),

                  // --- Các button lựa chọn ---
                  ...widget.question.options.map((option) {
                    return ActivityOptionButton(
                      title: option.moTa,
                      subtitle: _subtitleMap[option.answer] ?? "",
                      isSelected: _selectedLevel == option.answer,
                      onPressed: () => _selectLevel(option.answer),
                    );
                  }).toList(),
                  SizedBox(height: context.h(0.05)), // Khoảng cách dưới cùng

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
                    child: AnimatedStartButton(
                      text: "Tiếp tục",
                      onPressed: _selectedLevel == null
                          ? null
                          : () {
                              final provider = Provider.of<QuestionProvider>(
                                context,
                                listen: false,
                              );
                              final nextQuestion = provider.getQuestionByIndex(
                                6,
                              );
                              if (nextQuestion != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActivityLevelScreen(
                                      question: nextQuestion,
                                      fullname: widget.fullname,
                                      gender: widget.gender,
                                      height: widget.height,
                                      weight: widget.weight,
                                      age: widget.age,
                                      goal: _selectedLevel,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
