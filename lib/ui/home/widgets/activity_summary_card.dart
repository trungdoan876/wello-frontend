// lib/widgets/activity_summary_card.dart
import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({super.key});

  Widget _buildActivityItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: context.sp(3.8),
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: context.h(0.005)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.sp(5.0),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.06),
        vertical: context.h(0.02),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(4.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActivityItem(context, 'Di chuyển', '0 kcal'),
          Container(height: context.h(0.04), width: 1, color: Colors.grey.shade300),
          _buildActivityItem(context, 'Bước', '000'),
          Container(height: context.h(0.04), width: 1, color: Colors.grey.shade300),
          _buildActivityItem(context, 'Thời gian', '0 phút'),

        ],
      ),
    );
  }
}