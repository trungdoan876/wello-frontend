import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class CalorieCard extends StatelessWidget {
  const CalorieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.06)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "1335",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xffF7424D),
                  ),
                ),
                Text(
                  "Kcal/ngày",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.7),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffF7424D),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(0.15)),
          // Right: image circle with overlayed text
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: context.w(0.3),
                height: context.w(0.3),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/circle_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: context.w(0.25),
                height: context.w(0.25),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "1335\n",
                          style:GoogleFonts.baloo2(
                            fontSize: context.sp(4.6),
                            fontWeight: FontWeight.w900,
                            color:  const Color(0xff5BC0E4),
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: "Calo cần nạp",
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.8),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffADA6A7),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
