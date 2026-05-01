import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/ui/question/age_weight_question/weight_page.dart';
import 'package:wello_frontend/ui/question/activity_question/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class TargetLevelScreen extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? targetWeight;
  final int? age;
  final int? userId;
  final String? initialGoal;
  final String? buttonText;
  final Future<bool> Function(String goal)? onUpdate;
  const TargetLevelScreen({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.targetWeight,
    this.age,
    this.userId,
    this.initialGoal,
    this.buttonText,
    this.onUpdate,
  });

  @override
  State<TargetLevelScreen> createState() => _TargetLevelScreenState();
}

class _TargetLevelScreenState extends State<TargetLevelScreen> {
  late String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialGoal;
  }

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
    print('Muc tieu da chon: $level');
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
                      text: widget.buttonText ?? "Tiếp tục",
                      onPressed: _selectedLevel == null
                          ? null
                          : () async {
                              if (widget.onUpdate != null) {
                                // Update mode
                                print(
                                  '[TargetScreen] Che do cap nhat - dang goi onUpdate voi $_selectedLevel',
                                );
                                final success = await widget.onUpdate!(
                                  _selectedLevel!,
                                );
                                if (!mounted) return;
                                if (success) {
                                  Navigator.pop(context, _selectedLevel);
                                }
                              } else {
                                // Normal onboarding flow
                                final provider = Provider.of<QuestionProvider>(
                                  context,
                                  listen: false,
                                );
                                final nextQuestion = provider
                                    .getQuestionByIndex(5);
                                if (nextQuestion != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WeightPage(
                                        question: nextQuestion,
                                        fullname: widget.fullname,
                                        gender: widget.gender,
                                        height: widget.height,
                                        age: widget.age,
                                        goal: _selectedLevel,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                }
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
