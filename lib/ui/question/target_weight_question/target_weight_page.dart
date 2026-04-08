import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/ui/question/activity_question/activity_level_screen.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/data/data_source/survey_remote_data_source.dart';
import 'package:wello_frontend/data/models/responses/calculate_bmi_response_model.dart';
import '../age_weight_question/widgets/number_box.dart';
import '../age_weight_question/widgets/bmi_display_card.dart';

class TargetWeightPage extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? age;
  final String? goal;
  final int? userId;
  final int? initialTargetWeight;

  const TargetWeightPage({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.userId,
    this.initialTargetWeight,
  });

  @override
  State<TargetWeightPage> createState() => _TargetWeightPageState();
}

class _TargetWeightPageState extends State<TargetWeightPage> {
  late int targetWeight;
  CalculateBmiResponse? targetBmiData;

  @override
  void initState() {
    super.initState();
    targetWeight = widget.initialTargetWeight ?? widget.weight ?? 60;
    _calculateBmi();
  }

  Future<void> _calculateBmi() async {
    if (widget.height == null) return;
    
    try {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final response = await surveyProvider.calculateBmi(
        weight: targetWeight,
        height: widget.height!,
        goal: widget.goal,
      );
      
      if (mounted) {
        setState(() {
          targetBmiData = response;
        });
      }
    } catch (e) {
      print('Loi khi tinh BMI trong TargetWeightPage: $e');
    }
  }

  void _onTargetWeightChanged() {
    _calculateBmi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- APP BAR ----
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + context.h(0.05)),
        child: Padding(
          padding: EdgeInsets.only(top: context.h(0.05)),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
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

      // ---- BACKGROUND ----
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_question_weight.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.05),
              vertical: context.h(0.02),
            ),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                SizedBox(height: context.h(0.07)),

                // ----- TITLE -----
                Text(
                  widget.question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xffEBCF23),
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // ----- TARGET WEIGHT BOX -----
                Container(
                  padding: EdgeInsets.all(context.w(0.05)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: NumberBox(
                    title: "Mục tiêu",
                    unit: widget.question.unit ?? "kg",
                    value: targetWeight,
                    onMinus: () {
                      setState(() {
                        if (targetWeight > 1) targetWeight--;
                      });
                      _onTargetWeightChanged();
                    },
                    onPlus: () {
                      setState(() => targetWeight++);
                      _onTargetWeightChanged();
                    },
                  ),
                ),

                SizedBox(height: context.h(0.02)),

                // ----- TARGET BMI DISPLAY -----
                if (widget.height != null)
                  BmiDisplayCard(
                    bmiData: targetBmiData,
                  ),

                SizedBox(height: context.h(0.05)),

                // ---- NEXT BUTTON ----
                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed: () async {
                      // Navigate to Activity Level Screen
                      final provider = Provider.of<QuestionProvider>(
                        context,
                        listen: false,
                      );
                      final nextQuestion = provider.getQuestionByIndex(7);
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
                              targetWeight: targetWeight,
                              age: widget.age,
                              goal: widget.goal,
                              userId: widget.userId,
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
        ),
      ),
      ),
    );
  }
}
