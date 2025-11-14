import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/question/widgets/question_header.dart';
import 'package:wello_frontend/ui/question/widgets/question_title.dart';
import 'package:wello_frontend/ui/question/widgets/question_description_box.dart';
import 'package:wello_frontend/ui/question/widgets/yes_no_option.dart';
import 'package:wello_frontend/ui/question/widgets/next_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class YesNoQuestionPage extends StatefulWidget {
  const YesNoQuestionPage({super.key});

  @override
  State<YesNoQuestionPage> createState() => _YesNoQuestionPageState();
}

class _YesNoQuestionPageState extends State<YesNoQuestionPage> {
  // Câu hỏi và mô tả
  final String question = "Câu dưới đây có đúng với bạn không?";
  final String description =
      "Mình sợ sẽ không còn thời gian làm những điều mình thích vì quá bận rộn với việc tập luyện và lên kế hoạch bữa ăn.";

  String? selectedAnswer;

  void _selectAnswer(String value) {
    setState(() => selectedAnswer = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ======= Header =======
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.06), // ~24px
                vertical: context.h(0.02),   // ~16px
              ),
              child: const QuestionHeader(),
            ),

            // ======= Nội dung chính =======
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.06), // ~24px
                  vertical: context.h(0.015),  // ~12px
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Câu hỏi chính
                    QuestionTitle(text: question),
                    SizedBox(height: context.h(0.05)), // ~40px

                    // Hộp mô tả
                    QuestionDescriptionBox(text: description),
                    SizedBox(height: context.h(0.09)), // ~80px

                    // Hai lựa chọn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        YesNoOption(
                          icon: Icons.check_circle,
                          label: "Đúng",
                          isSelected: selectedAnswer == "yes",
                          onTap: () => _selectAnswer("yes"),
                        ),
                        YesNoOption(
                          icon: Icons.cancel,
                          label: "Không",
                          isSelected: selectedAnswer == "no",
                          onTap: () => _selectAnswer("no"),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Nút Tiếp tục
                    NextButton(
                      enabled: selectedAnswer != null,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Bạn đã chọn: ${selectedAnswer == 'yes' ? 'Đúng' : 'Không'}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: context.h(0.03)), // ~24px
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}