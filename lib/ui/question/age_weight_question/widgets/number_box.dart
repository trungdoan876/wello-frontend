import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class NumberBox extends StatelessWidget {
  final String title;
  final String unit;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const NumberBox({
    super.key,
    required this.title,
    required this.unit,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(0.7),                // 🔥 responsive width
      padding: EdgeInsets.all(context.w(0.04)), // 🔥 responsive padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(context.w(0.05)), // 🔥 responsive bo góc
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(8),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xffF8BD17),
                ),
              ),

            SizedBox(width: context.w(0.07)),

              if (unit.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.02),
                    vertical: context.h(0.0),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8BF15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unit,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

            ],
          ),


          SizedBox(height: context.h(0.015)),

         Text(
          "$value",
          style: TextStyle(
            fontSize: context.sp(10),
            fontWeight: FontWeight.bold,
            color: const Color(0xffF8BD17),
          ),
        ),

      //  SizedBox(height: context.h(0.01)),

        Container(
          width: context.w(0.4),           // 🔥 độ dài gạch chân (tự chỉnh)
          height: context.h(0.004),         // 🔥 độ dày
          color: const Color(0xffF8BD17),   // 🔥 màu giống text
        ),
          SizedBox(height: context.h(0.025)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              button("-", onMinus, context),
              SizedBox(width: context.w(0.1)),
              button("+", onPlus, context),
            ],
          ),
         // SizedBox(height: context.h(0.015)),
        ],
      ),
    );
  }


  // Nút cộng – trừ responsive
  Widget button(String text, VoidCallback onTap, BuildContext context) {
  double size = context.w(0.14);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xffF8BD17),  // vàng đậm
            Color(0xffF4D106),  // vàng nhạt
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.sp(8),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

}
