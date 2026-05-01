import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/repositories/nutrition_repository_impl.dart';
import 'package:wello_frontend/data/data_source/nutrition_remote_data_source.dart';
import 'package:wello_frontend/domain/entities/weight_history_item.dart';
import 'package:wello_frontend/data/repositories/profile_repository.dart';

/// Complete weight goal card widget containing header, title, chart, and labels.
class WeightGoalCard extends StatefulWidget {
  final List<double>? data;
  final String? targetWeight;
  final List<String>? xLabels;

  const WeightGoalCard({Key? key, this.data, this.targetWeight, this.xLabels})
    : super(key: key);

  @override
  State<WeightGoalCard> createState() => _WeightGoalCardState();
}

class _WeightGoalCardState extends State<WeightGoalCard> {
  List<double> _data = const [59.9, 59.8, 60.1, 60.3, 58.8];
  List<String>? _labels;
  String _target = '60kg';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initFromProps();
    _loadFromApi();
  }

  void _initFromProps() {
    if (widget.data != null && widget.data!.isNotEmpty) {
      _data = widget.data!;
    }
    if (widget.xLabels != null && widget.xLabels!.length >= 2) {
      _labels = widget.xLabels!;
    }
    if (widget.targetWeight != null) {
      _target = widget.targetWeight!;
    }
  }

  Future<void> _loadFromApi() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final creds = await AuthHelper.getCredentials();
      final userId = creds?.userId;
      if (userId == null) {
        throw Exception('No user session');
      }

      final repo = NutritionRepositoryImpl(
        remoteDataSource: NutritionRemoteDataSource(),
      );
      final List<WeightHistoryItem> history = await repo.getWeightHistory(
        creds?.token ?? '',
        userId.toString(),
      );

      if (history.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Chưa có lịch sử cân nặng';
        });
        return;
      }

      history.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      final weights = history.map((e) => e.weight).toList();
      final fmt = DateFormat("dd 'thg' MM");
      final labels = [
        fmt.format(history.first.recordedAt),
        fmt.format(history.last.recordedAt),
      ];

      setState(() {
        _data = weights;
        _labels = labels;
        _target = '${weights.last.toStringAsFixed(1)}kg';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainYellow = Color(0xFFFFC107);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '(gợi ý) ' + _target,
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
                  InkWell(
                    onTap: _showUpdateWeightSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: mainYellow,
                      size: context.sp(7.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.02)),
              if (_loading)
                SizedBox(
                  height: context.h(0.12),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xffEBCF23)),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: context.h(0.02)),
                  child: Text(
                    _error!,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      color: Colors.red,
                    ),
                  ),
                )
              else
                WeightChart(data: _data, xLabels: _labels),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showUpdateWeightSheet() async {
    int editWeight = _data.isNotEmpty ? _data.last.toInt() : 60;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: context.w(0.06),
            right: context.w(0.06),
            top: context.h(0.02),
            bottom: MediaQuery.of(ctx).viewInsets.bottom + context.h(0.02),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: context.h(0.008)),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: context.h(0.02)),
                  Text(
                    'Cập nhật cân nặng',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(7),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4C494C),
                    ),
                  ),
                  SizedBox(height: context.h(0.02)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleButton(Icons.remove, () {
                        setModalState(() {
                          editWeight = (editWeight - 1).clamp(1, 400);
                        });
                      }),
                      SizedBox(width: context.w(0.08)),
                      Text(
                        editWeight.toString(),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(8),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4C494C),
                        ),
                      ),
                      SizedBox(width: context.w(0.08)),
                      _circleButton(Icons.add, () {
                        setModalState(() {
                          editWeight = (editWeight + 1).clamp(1, 400);
                        });
                      }),
                    ],
                  ),
                  SizedBox(height: context.h(0.015)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(0.03),
                      vertical: context.h(0.008),
                    ),
                    decoration: BoxDecoration(
                      color: const ui.Color.fromARGB(255, 127, 226, 162),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'kg',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(0.02)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final creds = await AuthHelper.getCredentials();
                          if (creds == null) {
                            throw Exception('Không tìm thấy phiên đăng nhập');
                          }
                          final userId = creds.userId;
                          final int intWeight = editWeight;

                          final repo = ProfileRepository();
                          final ok = await repo.updateWeight(
                            token: creds.token,
                            userId: userId,
                            weight: intWeight,
                          );
                          if (!mounted) return;
                          if (ok) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cập nhật cân nặng'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            // Reload chart data
                            await _loadFromApi();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật thất bại'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        padding: EdgeInsets.symmetric(
                          vertical: context.h(0.016),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cập nhật',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(6),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(0.01)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF6B6B6B)),
      ),
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

        SizedBox(height: context.h(0.02)),

        // X axis labels (first and last)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels.first,
              style: TextStyle(
                fontSize: context.sp(4.0),
                color: Color(0xff8B8989),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              labels.last,
              style: TextStyle(
                fontSize: context.sp(4.0),
                color: Color(0xff8B8989),
                fontWeight: FontWeight.bold,
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

    // Keep only finite points to avoid NaN/Infinity painting crashes.
    final cleaned = data.where((v) => v.isFinite).toList();
    if (cleaned.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xff17B2A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()..color = const Color(0xff17B2A8);

    // compute min/max with padding
    double minV = cleaned.reduce((a, b) => a < b ? a : b);
    double maxV = cleaned.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) {
      minV -= 1;
      maxV += 1;
    }
    final vRange = maxV - minV;

    final int n = cleaned.length;
    final double leftPadding = size.width * 0.12; //chỉnh chart qua phải
    final double rightPadding = size.width * 0.04;
    final double topPadding = size.height * 0.08;
    final double bottomPadding = size.height * 0.08;

    final double chartW = size.width - leftPadding - rightPadding;
    final double chartH = size.height - topPadding - bottomPadding;
    if (!chartW.isFinite || !chartH.isFinite || chartW <= 0 || chartH <= 0) {
      return;
    }

    // build points
    final List<Offset> points = [];
    final double xStepDivisor = n > 1 ? (n - 1).toDouble() : 1.0;
    for (int i = 0; i < n; i++) {
      final double x = leftPadding + chartW * (i / xStepDivisor);
      final double normalized = (cleaned[i] - minV) / vRange;
      final double y = topPadding + (1 - normalized) * chartH;
      if (x.isFinite && y.isFinite) {
        points.add(Offset(x, y));
      }
    }

    if (points.isEmpty) return;

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

    // thin horizontal grid line at max value level
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..strokeWidth = 1;
    double yForValue(double val) {
      final double normalized = (val - minV) / vRange;
      return topPadding + (1 - normalized) * chartH;
    }

    final double yMax = yForValue(maxV);
    final double yMin = yForValue(minV);
    canvas.drawLine(
      Offset(leftPadding, yMax),
      Offset(size.width - rightPadding, yMax),
      gridPaint,
    );

    // draw line
    canvas.drawPath(linePath, paintLine);

    // draw dots
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (!p.dx.isFinite || !p.dy.isFinite) continue;
      // outer white border
      canvas.drawCircle(p, 6.0, Paint()..color = Colors.white);
      // green dot
      canvas.drawCircle(p, 4.0, paintPoint);
    }

    // draw y-axis labels: top and bottom (values)
    _drawText(
      canvas,
      '${maxV.toStringAsFixed(1)}',
      Offset(1, yMax - 10),
      15.0,
      FontWeight.bold,
      const Color(0xff8B8989),
    );
    _drawText(
      canvas,
      '${minV.toStringAsFixed(1)}',
      Offset(4, yMin - 10),
      15.0,
      FontWeight.bold,
      const Color(0xff8B8989),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double fontSize,
    FontWeight fontWeight,
    Color color,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
