import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/ui/question/age_weight_question/weight_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/height_slider.dart';

class HeightPage extends StatefulWidget {
  final Question question;
  final String? fullname;
  final String? gender;
  final int? userId;
  final int? initialHeight;
  final String? buttonText;
  final Future<bool> Function(int height)? onUpdate;

  const HeightPage({
    super.key,
    required this.question,
    this.fullname,
    this.gender,
    this.userId,
    this.initialHeight,
    this.buttonText,
    this.onUpdate,
  });

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  late double height;

  @override
  void initState() {
    super.initState();
    height = widget.initialHeight?.toDouble() ?? 165.0;
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
              color: Color(0xffEBCF23),
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
            image: AssetImage(
              "assets/images/bg_question_height.png",
            ), // đổi ảnh của bạn
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

                // ----- HEIGHT SLIDER WIDGET -----
                Container(
                  padding: EdgeInsets.all(context.w(0.05)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: HeightSlider(
                    height: height,
                    unit: widget.question.unit ?? "cm",
                    onChanged: (v) {
                      setState(() => height = v);
                    },
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // ---- NEXT BUTTON (OPTIONAL) ----
                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: widget.buttonText ?? "Tiếp tục",
                    onPressed: () async {
                      print('[HeightPage] onUpdate: ${widget.onUpdate}');
                      if (widget.onUpdate != null) {
                        // Update mode
                        print(
                          '[HeightPage] Update mode - calling onUpdate with ${height.toInt()}',
                        );
                        final success = await widget.onUpdate!(height.toInt());
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đã cập nhật chiều cao thành công',
                                ),
                                backgroundColor: Color(0xFF22C55E),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context, height.toInt());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật chiều cao thất bại'),
                                backgroundColor: Color(0xFFEF4444),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
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
                              builder: (_) => WeightPage(
                                question: nextQuestion,
                                fullname: widget.fullname,
                                gender: widget.gender,
                                height: height.toInt(),
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
