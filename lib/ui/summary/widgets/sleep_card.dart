import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../../../data/models/responses/survey_response_model.dart';

class SleepCard extends StatelessWidget {
  final SurveyResponseModel survey;
  const SleepCard({super.key, required this.survey});

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
      child: Column(
        children: [
          Row(
            children: [
              // Left: Giờ ngủ mục tiêu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${survey.sleepTargetHours?.toStringAsFixed(1) ?? '8.0'} giờ",
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(7),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xff6C63FF),
                      ),
                    ),
                    Text(
                      "Mục tiêu giấc ngủ",
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffA3A1A1),
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Icon giấc ngủ
              Icon(
                Icons.nights_stay_rounded,
                size: context.w(0.15),
                color: const Color(0xff6C63FF),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),
          // Divider
          Container(
            width: double.infinity,
            height: 1.5,
            color: Colors.grey.withOpacity(0.2),
          ),
          SizedBox(height: context.h(0.02)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeInfo(
                context,
                "Đi ngủ lúc",
                survey.sleepBedtimeTarget ?? "22:30",
                Icons.bedtime_outlined,
              ),
              _buildTimeInfo(
                context,
                "Thức dậy lúc",
                survey.sleepWakeTimeTarget ?? "06:30",
                Icons.wb_sunny_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, String label, String time, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: context.sp(5), color: const Color(0xff6C63FF).withOpacity(0.7)),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4),
                color: const Color(0xffADA6A7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(5),
            fontWeight: FontWeight.bold,
            color: const Color(0xff4C494C),
          ),
        ),
      ],
    );
  }
}
