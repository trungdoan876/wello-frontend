import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/question_header.dart';
import 'widgets/option_item.dart';
import 'widgets/next_button.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? _selectedIndex;

  // Dữ liệu mẫu
  final String questionTitle = 'Chất lượng giấc ngủ ban đêm của bạn thế nào?';
  final String questionSubtitle =
      'Ngủ đủ giấc là chìa khóa cho sức khỏe và vóc dáng lý tưởng';
  final List<String> options = [
    'Ít hơn 5 tiếng',
    '5 - 6 Tiếng',
    '7 - 8 Tiếng',
    'Hơn 8 Tiếng',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.07), // ~27px
            vertical: context.h(0.02),   // ~16px
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QuestionHeader(),

              SizedBox(height: context.h(0.035)), // ~30px

              // Câu hỏi chính
              Center(
                child: Text(
                  questionTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(6.2), // ~24px
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: context.h(0.015)), // ~12px

              Center(
                child: Text(
                  questionSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(3.6), // ~14px
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: context.h(0.05)), // ~40px

              // Danh sách lựa chọn
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => SizedBox(height: context.h(0.03)), // ~25px
                  itemBuilder: (context, index) {
                    return OptionItem(
                      text: options[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                    );
                  },
                ),
              ),

              SizedBox(height: context.h(0.02)), // ~16px

              // Nút "Tiếp theo"
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.03)), // ~12px
                child: NextButton(
                  enabled: _selectedIndex != null,
                  onPressed: () {
                    if (_selectedIndex != null) {
                      debugPrint("Chọn: ${options[_selectedIndex!]}");
                      // TODO: Chuyển trang tiếp theo
                    }
                  },
                ),
              ),

              SizedBox(height: context.h(0.03)), // ~25px
            ],
          ),
        ),
      ),
    );
  }
}