// lib/screens/activity_level_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question_1/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart'; // Dùng responsive của bạn

// Định nghĩa Enum cho các mức độ hoạt động
enum TargetLevel {
  gain_weight, // Ít vận động
  lose_weight,     // Vận động nhẹ
  keep_fit,  // Vận động vừa
}

class TargetLevelScreen extends StatefulWidget {
  const TargetLevelScreen({super.key});

  @override
  State<TargetLevelScreen> createState() => _TargetLevelScreenState();
}

class _TargetLevelScreenState extends State<TargetLevelScreen> {
  TargetLevel? _selectedLevel; // Biến lưu trữ mức độ được chọn

  final List<Map<String, dynamic>> _activityOptions = [
    {
      'level': TargetLevel.gain_weight,
      'title': 'Tăng cân',
      'subtitle': 'Ăn nhiều hơn, tăng cơ và cân nặng',
    },
    {
      'level': TargetLevel.lose_weight,
      'title': 'Giảm cân',
      'subtitle': 'Ăn kiểm soát để giảm mỡ thừa',
    },
    {
      'level': TargetLevel.keep_fit,
      'title': 'Giữ dáng',
      'subtitle': 'Giữ cân năng ổn định , sống khỏe',
    },
    
  ];

  void _selectLevel(TargetLevel level) {
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
            'assets/images/question_bg_2.png', // Hình nền
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