// lib/screens/activity_level_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question_1/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart'; // Dùng responsive của bạn

// Định nghĩa Enum cho các mức độ hoạt động
enum ActivityLevel {
  sedentary, // Ít vận động
  light,     // Vận động nhẹ
  moderate,  // Vận động vừa
  heavy,     // Vận động nặng
  veryHeavy, // Rất nặng
}

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  ActivityLevel? _selectedLevel; // Biến lưu trữ mức độ được chọn

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
    setState(() {
      _selectedLevel = level;
    });
    // In ra lựa chọn để kiểm tra (hoặc chuyển trang)
    print('Selected Activity Level: $level'); 
    // Thêm logic Navigator.push ở đây sau khi chọn xong
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFFFBEA);
    const Color mainYellow = Color(0xFFEBCF23);
    final size = MediaQuery.of(context).size; // Lấy kích thước màn hình
    return Scaffold(
      backgroundColor: lightCream,
      body: SafeArea(
        child: Stack(
          children: [
            // --- Hình nền full màn hình ---
        SizedBox(
          width: size.width,
          height: size.height,
          child: Image.asset(
            'assets/images/question_bg_1.png', // Hình nền
            fit: BoxFit.cover, // Bao phủ toàn màn hình
          ),
        ),

        // --- Nội dung chính ---
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: context.h(0.02)),
                  
                  // --- Tiêu đề Wello ---
                  Text(
                    'Wello',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                      fontSize: context.sp(10.0),
                      color: mainYellow,
                    ),
                  ),
                  SizedBox(height: context.h(0.03)),
                  
                  // --- Câu hỏi Chính ---
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
                  SizedBox(height: context.h(0.02)),
                  
                  // --- Danh sách các nút chọn mức độ hoạt động ---
                  ..._activityOptions.map((option) {
                    return ActivityOptionButton(
                      title: option['title'],
                      subtitle: option['subtitle'],
                      isSelected: _selectedLevel == option['level'],
                      onPressed: () => _selectLevel(option['level']),
                    );
                  }).toList(),
                  
                //  SizedBox(height: context.h(0.05)),
                  
                  // Phần khoảng trống cuối cùng để tránh bị che
                //  SizedBox(height: context.h(0.15)), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}