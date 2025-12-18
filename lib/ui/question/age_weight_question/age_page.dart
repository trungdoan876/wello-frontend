import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/data/models/question.dart';
import 'package:wello_frontend/ui/question/target_question/target_screen.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

import 'widgets/number_box.dart';

class AgePage extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? userId;
  const AgePage({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.userId,
  });

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  int age = 20; // tuổi mặc định

  String _getUnit() {
    if (widget.question.unit == "inputNumber") return "";
    return widget.question.unit ?? "";
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
            image: AssetImage("assets/images/bg_question_age.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.05),
              vertical: context.h(0.02),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.h(0.07)),

                // ----- TITLE -----
                Text(
                  widget.question.question,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xffEBCF23),
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // ----- AGE BOX -----
                Container(
                  padding: EdgeInsets.all(context.w(0.05)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: NumberBox(
                    title: "Tuổi",
                    unit: _getUnit(),
                    value: age,
                    onMinus: () {
                      setState(() {
                        if (age > 1) age--;
                      });
                    },
                    onPlus: () => setState(() => age++),
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // ---- NEXT BUTTON ----
                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed: () {
                      final provider = Provider.of<QuestionProvider>(
                        context,
                        listen: false,
                      );
                      final nextQuestion = provider.getQuestionByIndex(5);
                      if (nextQuestion != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TargetLevelScreen(
                              question: nextQuestion,
                              fullname: widget.fullname,
                              gender: widget.gender,
                              height: widget.height,
                              weight: widget.weight,
                              age: age,
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
    );
  }
}
