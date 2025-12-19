import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

/// Reusable Information Bottom Sheet based on the provided design
class InfoBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? details;
  final String? note;
  final String? tip;

  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.details,
    this.note,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    // Light theme colors with darker shades for better readability
    const Color bgColor = Colors.white;
    // A slightly deeper yellow/gold for better contrast on white
    const Color primaryYellow = Color(0xFFC7A700); 
    const Color textColor = Colors.black;
    const Color subTextColor = Colors.black87;
    const Color tipBgColor = Color(0xFFFFFBEA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.sp(8)),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(0.06),
              context.h(0.02),
              context.w(0.06),
              context.h(0.04),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Center the whole column for balanced look
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: context.w(0.12),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: context.h(0.03)),

                // Title centered
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(6.5),
                    fontWeight: FontWeight.bold,
                    color: primaryYellow,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: context.h(0.025)),

                // Description (Left aligned for readability, or centered if preferred - sticking to center for uniform look)
                _buildRichDescription(description, subTextColor, context, boldColor: textColor, textAlign: TextAlign.center),
                
                SizedBox(height: context.h(0.025)),

                // Details (Bullet points - usually better left-aligned)
                if (details != null && details!.isNotEmpty)
                  ...details!.map((detail) => Padding(
                        padding: EdgeInsets.only(bottom: context.h(0.015)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: subTextColor, fontSize: context.sp(4.5), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: _buildRichDescription(detail, subTextColor, context, boldColor: textColor),
                            ),
                          ],
                        ),
                      )),

                // Note section
                if (note != null) ...[
                  SizedBox(height: context.h(0.01)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lưu ý',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(0.01)),
                  Padding(
                    padding: EdgeInsets.only(left: context.w(0.02)),
                    child: _buildRichDescription('• $note', subTextColor, context, boldColor: textColor),
                  ),
                ],

                // Tip section
                if (tip != null) ...[
                  SizedBox(height: context.h(0.025)),
                  Container(
                    padding: EdgeInsets.all(context.sp(3)),
                    decoration: BoxDecoration(
                      color: tipBgColor,
                      borderRadius: BorderRadius.circular(context.sp(4)),
                      border: Border.all(color: primaryYellow.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👉 ', style: TextStyle(fontSize: context.sp(5))),
                        Expanded(
                          child: _buildRichDescription(tip!, subTextColor, context, boldColor: textColor),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: context.h(0.04)),

                // "Đã hiểu" Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEBCF23), // Restored the previous bright yellow
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.sp(10)),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Đã hiểu',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Close button "X" on top right
          Positioned(
            top: context.h(0.02),
            right: context.w(0.04),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.grey.shade500, size: context.sp(6)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple parser to handle **bold text** in strings
  Widget _buildRichDescription(String text, Color color, BuildContext context, {Color? boldColor, TextAlign textAlign = TextAlign.start}) {
    if (!text.contains('**')) {
      return Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.baloo2(
          fontSize: context.sp(4.5),
          color: color,
          height: 1.5,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Bold part
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(fontWeight: FontWeight.bold, color: boldColor ?? Colors.black),
        ));
      } else {
        // Normal part
        spans.add(TextSpan(text: parts[i]));
      }
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: GoogleFonts.baloo2(
          fontSize: context.sp(4.5),
          color: color,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  /// Static helper to show the sheet
  static void show(BuildContext context, {
    required String title,
    required String description,
    List<String>? details,
    String? note,
    String? tip,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InfoBottomSheet(
        title: title,
        description: description,
        details: details,
        note: note,
        tip: tip,
      ),
    );
  }
}
