import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/data/models/question.dart';
import 'package:wello_frontend/ui/question/gender_question/widgets/gender_selector.dart';
import 'package:wello_frontend/ui/question/height_question/height_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class GenderPage extends StatefulWidget {
  final Question question;
  final String? fullname;
  const GenderPage({super.key, required this.question, this.fullname});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String selectedGender = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👉 AppBar giống HeightPage
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
              color: Color(0xffEBCF23), // màu icon back
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

      // 👉 Body giữ nguyên
      body: Container(
        width: context.w(1),
        height: context.h(1),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_question_gender.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.07)),
            child: Column(
              children: [
                SizedBox(height: context.h(0.1)),

                Text(
                  widget.question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffEBCF23),
                  ),
                ),

                SizedBox(height: context.h(0.03)),

                GenderSelector(
                  selected: selectedGender,
                  options: widget.question.options,
                  onSelect: (value) {
                    setState(() => selectedGender = value);
                  },
                ),

                SizedBox(height: context.h(0.05)),

                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed: selectedGender.isEmpty
                        ? null
                        : () {
                            final provider = Provider.of<QuestionProvider>(
                              context,
                              listen: false,
                            );
                            final nextQuestion = provider.getQuestionByIndex(2);
                            if (nextQuestion != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HeightPage(
                                    question: nextQuestion,
                                    fullname: widget.fullname,
                                    gender: selectedGender,
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
    );
  }
}
