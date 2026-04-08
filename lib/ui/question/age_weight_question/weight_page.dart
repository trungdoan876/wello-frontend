import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/ui/question/age_weight_question/age_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/data/data_source/survey_remote_data_source.dart';
import 'package:wello_frontend/data/models/responses/calculate_bmi_response_model.dart';
import 'package:wello_frontend/ui/question/activity_question/activity_level_screen.dart';
import 'package:wello_frontend/ui/question/target_weight_question/target_weight_page.dart';
import 'widgets/number_box.dart';
import 'widgets/bmi_display_card.dart';

class WeightPage extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? age;
  final String? goal;
  final int? userId;
  final int? initialWeight;
  final String? buttonText;
  final Future<bool> Function(int weight)? onUpdate;
  const WeightPage({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.userId,
    this.initialWeight,
    this.buttonText,
    this.onUpdate,
  });

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  late int weight;
  CalculateBmiResponse? bmiData;

  @override
  void initState() {
    super.initState();
    weight = widget.initialWeight ?? 60;
    _calculateBmi();
  }

  Future<void> _calculateBmi() async {
    if (widget.height == null) return;
    
    try {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final response = await surveyProvider.calculateBmi(
        weight: weight,
        height: widget.height!,
        goal: widget.goal,
      );
      
      if (mounted) {
        setState(() {
          bmiData = response;
        });
      }
    } catch (e) {
      print('Loi khi tinh BMI trong WeightPage: $e');
    }
  }

  void _onWeightChanged() {
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

                // ----- WEIGHT BOX -----
                Container(
                  padding: EdgeInsets.all(context.w(0.05)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: NumberBox(
                    title: "Cân nặng",
                    unit: widget.question.unit ?? "kg",
                    value: weight,
                    onMinus: () {
                      setState(() {
                        if (weight > 1) weight--;
                      });
                      _onWeightChanged();
                    },
                    onPlus: () {
                      setState(() => weight++);
                      _onWeightChanged();
                    },
                  ),
                ),

                SizedBox(height: context.h(0.02)),

                // ----- BMI DISPLAY -----
                if (widget.height != null)
                  BmiDisplayCard(
                    bmiData: bmiData,
                  ),

                SizedBox(height: context.h(0.05)),

                // ---- NEXT BUTTON ----
                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: widget.buttonText ?? "Tiếp tục",
                    onPressed: () async {
                      if (widget.onUpdate != null) {
                        // Update mode
                          print(
                            '[WeightPage] Che do cap nhat - dang goi onUpdate voi $weight',
                          );
                        final success = await widget.onUpdate!(weight);
                        if (!mounted) return;
                        if (success) {
                          Navigator.pop(context, weight);
                        }
                      } else {
                        // Normal onboarding flow
                        final provider = Provider.of<QuestionProvider>(
                          context,
                          listen: false,
                        );
                        
                        // Check if user needs to set target weight
                        // Only show TargetWeightPage for LOSE_WEIGHT or GAIN_WEIGHT
                        if (widget.goal == 'LOSE_WEIGHT' || widget.goal == 'GAIN_WEIGHT') {
                          final nextQuestion = provider.getQuestionByIndex(6);
                          if (nextQuestion != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TargetWeightPage(
                                  question: nextQuestion,
                                  fullname: widget.fullname,
                                  gender: widget.gender,
                                  height: widget.height,
                                  weight: weight,
                                  age: widget.age,
                                  goal: widget.goal,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          }
                        } else {
                          // Skip TargetWeightPage for KEEP_FIT or MAINTAIN_WEIGHT
                          // Go directly to ActivityLevelScreen
                          final activityQuestion = provider.getQuestionByIndex(7);
                          if (activityQuestion != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityLevelScreen(
                                  question: activityQuestion,
                                  fullname: widget.fullname,
                                  gender: widget.gender,
                                  height: widget.height,
                                  weight: weight,
                                  age: widget.age,
                                  goal: widget.goal,
                                  userId: widget.userId,
                                  targetWeight: null, // No target weight for KEEP_FIT/MAINTAIN_WEIGHT
                                ),
                              ),
                            );
                          }
                        }
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
