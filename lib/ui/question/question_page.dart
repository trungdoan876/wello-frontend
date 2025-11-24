import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'widgets/gender_selector.dart';
import 'widgets/height_slider.dart';
import 'widgets/number_box.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String gender = "female";
  double height = 175;
  int weight = 60;
  int age = 21;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.w(1),
        height: context.h(1),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8E8),
          image: DecorationImage(
            image: AssetImage("assets/images/question_bg.png"),
            alignment: Alignment.bottomCenter,
            fit: BoxFit.contain,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.h(0.01)),

                /// TITLE
              Center(
                  child: Text(
                    'Wello',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                      fontSize: context.sp(12.0),
                      color: const Color(0xffEBCF23),
                    ),
                  ),
                ),
                SizedBox(height: context.h(0.02)),

                /// TEXT FIELD NAME
                Container(
                  padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.04)),
                  height: context.h(0.065),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffEBCF23),width: 2.0,),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: context.sp(4)),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Bạn muốn mình gọi bạn là ...",
                        hintStyle: TextStyle(fontSize: context.sp(4)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.03)),

                /// GENDER SELECTOR
                GenderSelector(
                  selected: gender,
                  onSelect: (value) => setState(() => gender = value), // gọi call back lớp cha 
                ),

                SizedBox(height: context.h(0.025)),

                /// HEIGHT SLIDER
                HeightSlider(
                  height: height,
                  onChanged: (v) => setState(() => height = v),
                ),

                SizedBox(height: context.h(0.02)),

                /// WEIGHT + AGE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NumberBox(
                      title: "Cân nặng",
                      unit: "kg",
                      value: weight,
                      onMinus: () => setState(() => weight--),
                      onPlus: () => setState(() => weight++),
                    ),
                    NumberBox(
                      title: "Tuổi",
                      unit: "",
                      value: age,
                      onMinus: () => setState(() => age--),
                      onPlus: () => setState(() => age++),
                    ),
                  ],
                ),

                SizedBox(height: context.h(0.05)),

                /// BUTTON
                Center(
                  child: SizedBox(
                    width: context.w(0.5),
                    child: AnimatedStartButton(
                      text: "Tiếp tục",
                      onPressed: () {},
                    ),
                  ),
                ),

               // SizedBox(height: context.h(0.10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
