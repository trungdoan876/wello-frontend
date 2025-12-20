import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/data/models/requests/survey_request_model.dart';
import 'package:wello_frontend/data/models/responses/survey_response_model.dart';
import 'package:wello_frontend/ui/summary/summary_page.dart';
import 'package:wello_frontend/ui/question/activity_question/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/data/data_source/user_preferences.dart';

class ActivityLevelScreen extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? age;
  final String? goal;
  final int? userId;
  final String? initialActivityLevel;
  final String? buttonText;
  final Future<bool> Function(String activityLevel)? onUpdate;

  const ActivityLevelScreen({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.userId,
    this.initialActivityLevel,
    this.buttonText,
    this.onUpdate,
  });

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  late String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialActivityLevel;
  }

  // Mapping tạm thời cho Title vì backend chưa trả về
  final Map<String, String> _titleMap = {
    "SEDENTARY": "Ít vận động",
    "LIGHT_ACTIVE": "Vận động nhẹ",
    "MODERATE_ACTIVE": "Vận động vừa",
    "HEAVY_ACTIVE": "Vận động nặng",
    "VERY_HEAVY_ACTIVE": "Rất nặng",
  };

  void _selectLevel(String level) {
    setState(() => _selectedLevel = level);
    print("Selected Activity Level: $level");
  }

  @override
  Widget build(BuildContext context) {
    const Color mainYellow = Color(0xffEBCF23);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // ---- APP BAR ----
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFFFF7DA), // Pastel cream color
          centerTitle: true,
          leadingWidth: context.w(0.2),
          iconTheme: IconThemeData(color: mainYellow, size: context.sp(10)),
          title: Text(
            "Wello",
            style: GoogleFonts.pacifico(
              fontSize: context.sp(12.0),
              color: mainYellow,
            ),
          ),
        ),
      ),

      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          // --- Hình nền ---
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              "assets/images/question_bg_1.png",
              fit: BoxFit.cover,
            ),
          ),

          // --- Nội dung chính ---
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.w(0.08),
              0,
              context.w(0.08),
              context.h(0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.h(0.02)),

                // ---- CÂU HỎI ----
                Text(
                  widget.question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8.0),
                    fontWeight: FontWeight.bold,
                    color: mainYellow,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: context.h(0.03)),

                // --- DANH SÁCH LỰA CHỌN ---
                ...widget.question.options.map((option) {
                  return ActivityOptionButton(
                    title: _titleMap[option.answer] ?? option.answer,
                    subtitle: option.moTa,
                    isSelected: _selectedLevel == option.answer,
                    onPressed: () => _selectLevel(option.answer),
                  );
                }).toList(),

                SizedBox(height: context.h(0.05)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.08),
                    vertical: context.h(0.02),
                  ),
                  child: Consumer<SurveyProvider>(
                    builder: (context, surveyProvider, child) {
                      return AnimatedStartButton(
                        text:
                            widget.buttonText ??
                            (surveyProvider.isLoading
                                ? "Đang gửi..."
                                : "Tiếp tục"),
                        onPressed:
                            _selectedLevel == null || surveyProvider.isLoading
                            ? null
                            : () async {
                                if (widget.onUpdate != null) {
                                  // Update mode
                                  print(
                                    '[ActivityLevelScreen] Update mode - calling onUpdate with $_selectedLevel',
                                  );
                                  final success = await widget.onUpdate!(
                                    _selectedLevel!,
                                  );
                                  if (!mounted) return;
                                  if (success) {
                                    Navigator.pop(context, _selectedLevel);
                                  }
                                } else {
                                  // Normal onboarding flow - submit survey
                                  final userId =
                                      await UserPreferences.getUserId();

                                  final request = SurveyRequestModel(
                                    userId: widget.userId ?? 1,
                                    fullname: widget.fullname ?? 'No name',
                                    gender: widget.gender ?? 'MALE',
                                    age: widget.age ?? 25,
                                    height: widget.height ?? 170,
                                    weight: widget.weight ?? 65,
                                    goal: widget.goal ?? 'KEEP_FIT',
                                    activityLevel: _selectedLevel!,
                                  );

                                  print(
                                    'Submitting survey with userId: ${userId ?? 1}',
                                  );

                                  try {
                                    await surveyProvider.submitSurvey(request);
                                    final result = surveyProvider.surveyResult;
                                    if (result != null) {
                                      final updatedResult = SurveyResponseModel(
                                        bmi: result.bmi,
                                        bmiStatus: result.bmiStatus,
                                        bmr: result.bmr,
                                        tdee: result.tdee,
                                        dailyCalories: result.dailyCalories,
                                        proteinGram: result.proteinGram,
                                        carbsGram: result.carbsGram,
                                        fatGram: result.fatGram,
                                        waterIntakeMl: result.waterIntakeMl,
                                        height: surveyProvider.height
                                            ?.toDouble(),
                                        weight: surveyProvider.weight
                                            ?.toDouble(),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SummaryPage(
                                            survey: updatedResult,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // show simple dialog on error
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Lỗi'),
                                        content: Text(
                                          surveyProvider.errorMessage ??
                                              e.toString(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Đóng'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
