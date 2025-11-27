import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

/// Complete weight goal card widget containing header, title, chart, and labels.
class WeightGoalCard extends StatelessWidget {
  final List<double> data;
  final String targetWeight;
  final List<String>? xLabels;

  const WeightGoalCard({
    Key? key,
    this.data = const [59.9, 59.8, 60.1, 60.3, 58.8],
    this.targetWeight = '60kg',
    this.xLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color mainYellow = Color(0xFFFFC107);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mục tiêu section (outside the box)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mục tiêu',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5.5),
                color: const Color(0xff585755),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '(gợi ý) ' + targetWeight,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                color: const Color(0xff6177D0),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(0.015)),
        // Chart box (inside BoxDecoration, includes Cân nặng + chart)
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cân nặng',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(7.0),
                      fontWeight: FontWeight.bold,
                      color: mainYellow,
                    ),
                  ),
                  SizedBox(width: context.w(0.02)),
                  Icon(
                    Icons.add_circle_outline,
                    color: mainYellow,
                    size: context.sp(7.0),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.02)),
              WeightChart(data: data, xLabels: xLabels),
            ],
          ),
        ),
      ],
    );
  }
}

/// A simple area + line weight chart used on the Home screen.
///
/// - Draws a gradient-filled area under the line, a stroked line, and circular points.
/// - Shows two x-axis labels (first and last) and two y-axis labels (top and bottom)
class WeightChart extends StatelessWidget {
  final List<double> data;
  final List<String>? xLabels; // optional labels for x axis

  const WeightChart({
    Key? key,
    this.data = const [59.9, 59.8, 60.1, 60.3, 58.8],
    this.xLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = xLabels ?? ['16 thg 11', '25 thg 11'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart area
        SizedBox(
          height: context.h(0.12),
          child: CustomPaint(
            painter: _WeightChartPainter(data: data),
            size: Size.infinite,
          ),
        ),

        SizedBox(height: context.h(0.015)),

        // X axis labels (first and last)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels.first,
              style: TextStyle(
                fontSize: context.sp(3.0),
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              labels.last,
              style: TextStyle(
                fontSize: context.sp(3.0),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> data;

  _WeightChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xff17B2A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()..color = const Color(0xff17B2A8);

    // compute min/max with padding
    double minV = data.reduce((a, b) => a < b ? a : b);
    double maxV = data.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) {
      minV -= 1;
      maxV += 1;
    }
    final vRange = maxV - minV;

    final int n = data.length;
    final double leftPadding = size.width * 0.04;
    final double rightPadding = size.width * 0.04;
    final double topPadding = size.height * 0.08;
    final double bottomPadding = size.height * 0.08;

    final double chartW = size.width - leftPadding - rightPadding;
    final double chartH = size.height - topPadding - bottomPadding;

    // build points
    final List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final double x = leftPadding + (chartW) * (i / (n - 1));
      final double normalized = (data[i] - minV) / vRange;
      final double y = topPadding + (1 - normalized) * chartH;
      points.add(Offset(x, y));
    }

    // path for line
    final Path linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0)
        linePath.moveTo(points[i].dx, points[i].dy);
      else
        linePath.lineTo(points[i].dx, points[i].dy);
    }

    // path for area (closed)
    final Path areaPath = Path.from(linePath);
    areaPath.lineTo(points.last.dx, size.height - bottomPadding / 2);
    areaPath.lineTo(points.first.dx, size.height - bottomPadding / 2);
    areaPath.close();

    // draw area with gradient
    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, topPadding),
        Offset(0, size.height),
        [const Color(0x9961C8F5), const Color(0x0031D7C2)],
      );
    canvas.drawPath(areaPath, fillPaint);

    // thin horizontal grid lines (top and mid)
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..strokeWidth = 1;
    // top grid at first point's y (approx top of data)
    canvas.drawLine(
      Offset(leftPadding, points.first.dy),
      Offset(size.width - rightPadding, points.first.dy),
      gridPaint,
    );

    // draw line
    canvas.drawPath(linePath, paintLine);

    // draw dots
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // outer white border
      canvas.drawCircle(p, 6.0, Paint()..color = Colors.white);
      // green dot
      canvas.drawCircle(p, 4.0, paintPoint);
    }

    // draw y-axis labels: top and bottom (values)
    _drawText(
      canvas,
      '${maxV.toStringAsFixed(1)}',
      Offset(4, points[0].dy - 10),
      12.0,
      Colors.grey.shade600,
    );
    _drawText(
      canvas,
      '${minV.toStringAsFixed(1)}',
      Offset(4, size.height - bottomPadding / 2 - 6),
      12.0,
      Colors.grey.shade600,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double fontSize,
    Color color,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
