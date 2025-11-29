import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question/age_weight_question/weight_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/height_slider.dart';
class HeightPage extends StatefulWidget {
  const HeightPage({super.key});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  double height = 165;   // chiều cao mặc định

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
            image: AssetImage("assets/images/bg_question_height.png"), // đổi ảnh của bạn
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
                  "Chiều cao hiện tại của bạn ?",
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
                            text: "Tiếp tục",
                            onPressed:() {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WeightPage(),
                                  ),
                                );
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
