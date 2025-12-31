import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:intl/intl.dart';
import '../../../data/models/responses/survey_response_model.dart';

class BMICard extends StatelessWidget {
  final SurveyResponseModel survey;
  final DateTime? recordedAt; // Thời gian cập nhật từ weight history
  const BMICard({super.key, required this.survey, this.recordedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.08)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BMI + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "BMI",
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${survey.bmi.toStringAsFixed(1)}",
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(8.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: context.sp(5.5),
                        color: Color(0xffA3A1A1),
                      ),
                      SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'd \'tháng\' M - HH:mm',
                        ).format(recordedAt ?? DateTime.now()),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5.5),
                          color: Color(0xffA3A1A1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    recordedAt != null
                        ? 'Cập nhật lần cuối'
                        : 'Cập nhật cân nặng',
                    style: GoogleFonts.baloo2(
                      color: Color(0xffEBCF23),
                      fontSize: context.sp(4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: context.h(0.02)),

          // full-width thin divider between BMI and metrics
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withOpacity(0.25),
          ),

          SizedBox(height: context.h(0.02)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Height
              Padding(
                padding: EdgeInsets.only(left: context.w(0.03)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.h(0.005)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey.height != null
                              ? "${survey.height!.toStringAsFixed(0)}cm"
                              : "-- cm",
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(6),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: context.h(0.001)),
                        Text(
                          "Chiều cao",
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right: Weight
              Padding(
                padding: EdgeInsets.only(right: context.w(0.03)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.weight != null
                          ? "${survey.weight!.toStringAsFixed(0)}kg"
                          : "-- kg",
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: context.h(0.001)),
                    Text(
                      "Cân nặng",
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
