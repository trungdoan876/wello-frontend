import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/responses/calculate_bmi_response_model.dart';

class BmiDisplayCard extends StatefulWidget {
  final CalculateBmiResponse? bmiData;
  final bool isLoading;

  const BmiDisplayCard({
    super.key,
    this.bmiData,
    this.isLoading = false,
  });

  @override
  State<BmiDisplayCard> createState() => _BmiDisplayCardState();
}

class _BmiDisplayCardState extends State<BmiDisplayCard> {
  Color _getStatusColor() {
    if (widget.bmiData == null) return Colors.grey;
    
    switch (widget.bmiData!.status) {
      case 'UNDERWEIGHT':
        return const Color(0xFFFF6B6B); // Red
      case 'NORMAL':
        return const Color(0xFF51CF66); // Green
      case 'OVERWEIGHT':
        return const Color(0xFFFFD93D); // Yellow
      case 'OBESE':
        return const Color(0xFFFF8C42); // Orange
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEBCF23)),
          ),
        ),
      );
    }

    if (widget.bmiData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // BMI Value - Only this part updates
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BMI: ',
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.bmiData!.bmi.toStringAsFixed(1),
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(),
                width: 2,
              ),
            ),
            child: Text(
              widget.bmiData!.statusText,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
          ),
          
          // Warning (if exists)
          if (widget.bmiData!.hasWarning) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B6B),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.bmiData!.warning!,
                      style: GoogleFonts.baloo2(
                        fontSize: 14,
                        color: const Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
