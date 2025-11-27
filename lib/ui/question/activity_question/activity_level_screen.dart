// lib/screens/activity_level_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question/target_question/target_screen.dart';
import 'package:wello_frontend/ui/question/activity_question/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

// --- Enum mức độ hoạt động ---
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  heavy,
  veryHeavy,
}

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  ActivityLevel? _selectedLevel;

  final List<Map<String, dynamic>> _activityOptions = [
    {
      'level': ActivityLevel.sedentary,
      'title': 'Ít vận động',
      'subtitle': 'Chủ yếu ngồi, không tập thể dục.',
    },
    {
      'level': ActivityLevel.light,
      'title': 'Vận động nhẹ',
      'subtitle': 'Tập nhẹ 1–3 buổi/tuần',
    },
    {
      'level': ActivityLevel.moderate,
      'title': 'Vận động vừa',
      'subtitle': 'Tập đều 3–5 buổi/tuần',
    },
    {
      'level': ActivityLevel.heavy,
      'title': 'Vận động nặng',
      'subtitle': 'Tập cường độ cao 6–7 buổi/tuần',
    },
    {
      'level': ActivityLevel.veryHeavy,
      'title': 'Rất nặng',
      'subtitle': 'Lao động nặng/vận động viên',
    },
  ];

  void _selectLevel(ActivityLevel level) {
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
        preferredSize: Size.fromHeight(kToolbarHeight + context.h(0.0)),
        child: Padding(
          padding: EdgeInsets.only(top: context.h(0.0)),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            leadingWidth: context.w(0.2),
            iconTheme: IconThemeData(
              color: mainYellow,
              size: context.sp(10),
            ),
            title: Text(
              "Wello",
              style: GoogleFonts.pacifico(
                fontSize: context.sp(12.0),
                color: mainYellow,
              ),
            ),
          ),
        ),
      ),

      extendBodyBehindAppBar: true,
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
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.h(0.12)),

                // ---- CÂU HỎI ----
                Text(
                  'Bạn vận động như thế\nnào?',
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
                ..._activityOptions.map((option) {
                  return ActivityOptionButton(
                    title: option['title'],
                    subtitle: option['subtitle'],
                    isSelected: _selectedLevel == option['level'],
                    onPressed: () => _selectLevel(option['level']),
                  );
                }).toList(),

               SizedBox(height: context.h(0.05)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed:_selectedLevel == null
                        ? null
                        : () {
                       Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TargetLevelScreen(),
                                  ),
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
