import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.06)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.05)),
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
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1950.0 ml",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8),
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Lượng nước bạn cần uống",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffA3A1A1),
                  ),
                ),
                SizedBox(height: context.h(0.03)),
                 // full-width thin divider between BMI and metrics
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                SizedBox(height: context.h(0.015)),
                Row(
                  children: [
                    Icon(Icons.access_time, size: context.sp(6), color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "Lần cuối cùng",
                     style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      color: const Color(0xffA3A1A1),
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.02)),
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: const Color(0xffEBCF23), size: context.sp(6)),
                    SizedBox(width: 4),
                    Text(
                      "Bật tính năng thông báo",
                      style: GoogleFonts.baloo2(
                        color: const Color(0xffEBCF23),
                        fontSize: context.sp(4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // RIGHT IMAGE
          SizedBox(
            width: context.w(0.25),
            child: Image.asset(
              "assets/images/water.png",
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }
}
