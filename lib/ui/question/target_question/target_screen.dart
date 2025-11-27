// lib/screens/activity_level_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question/activity_question/widgets/activity_option_button.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
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
    final size = MediaQuery.of(context).size; // Lấy kích thước màn hình
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
                    'Bạn vận động như thế\nnào?',
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
                  ..._activityOptions.map((option) {
                    return ActivityOptionButton(
                      title: option['title'],
                      subtitle: option['subtitle'],
                      isSelected: _selectedLevel == option['level'],
                      onPressed: () => _selectLevel(option['level']),
                    );
                  }).toList(),
                  SizedBox(height: context.h(0.05)), // Khoảng cách dưới cùng

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed:_selectedLevel == null
                        ? null
                        : () {
                      //  Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (_) => const ActivityLevelScreen(),
                      //             ),
                      //           );
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