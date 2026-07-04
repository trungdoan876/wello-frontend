import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/ui/question/height_question/height_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

import 'widgets/number_box.dart';

class AgePage extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? height;
  final int? weight;
  final int? targetWeight;
  final int? userId;
  final int? initialAge;
  final String? buttonText;
  final Future<bool> Function(int age)? onUpdate;

  const AgePage({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.height,
    this.weight,
    this.targetWeight,
    this.userId,
    this.initialAge,
    this.buttonText,
    this.onUpdate,
  });

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  late int age;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    age = widget.initialAge ?? 20;
  }

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
                    text: widget.buttonText ?? "Tiếp tục",
                    isLoading: _isLoading,
                    onPressed: () async {
                      if (_isLoading) return;
                      if (widget.onUpdate != null) {
                        setState(() { _isLoading = true; });
                        final success = await widget.onUpdate!(age);
                        if (!mounted) return;
                        setState(() { _isLoading = false; });
                        if (success) {
                          Navigator.pop(context, age);
                        }
                      } else {
                        // Normal onboarding flow
                        final provider = Provider.of<QuestionProvider>(
                          context,
                          listen: false,
                        );
                        final nextQuestion = provider.getQuestionByIndex(3);
                        if (nextQuestion != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HeightPage(
                                question: nextQuestion,
                                fullname: widget.fullname,
                                gender: widget.gender,
                                userId: widget.userId,
                              ),
                            ),
                          );
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
    );
  }
}
