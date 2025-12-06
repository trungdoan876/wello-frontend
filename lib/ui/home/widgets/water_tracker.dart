// lib/ui/home/widgets/water_tracker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  int _cupsDrunk = 0;
  final int _totalCups = 6;
  final String _targetMl = '1950ml';

  @override
  Widget build(BuildContext context) {
    final int waterDrunkMl =
        (_cupsDrunk *
                (int.tryParse(_targetMl.replaceAll('ml', '')) ?? 0) /
                _totalCups)
            .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Bạn đã uống bao nhiêu nước',
                softWrap: true,
                maxLines: 2,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.2),
                  color: const Color(0xff585755),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: context.w(0.02)),

            Text(
              '${waterDrunkMl}ml/$_targetMl',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                color: const Color(0xff6177D0),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),

        SizedBox(height: context.h(0.01)),

        // Cup row inside a single pill container
        Container(
          height: context.w(0.12) + context.h(0.04),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: context.w(0.02)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(4.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _totalCups,
            itemBuilder: (context, index) {
              final bool isFilled = index < _cupsDrunk;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFilled) {
                      _cupsDrunk = index;
                    } else {
                      _cupsDrunk = index + 1;
                    }
                  });
                },
                child: Container(
                  width: context.w(0.12),
                  margin: EdgeInsets.only(right: context.w(0.01)),
                  child: Center(
                    child: GlassCup(
                      width: context.w(0.10),
                      height: context.w(0.12),
                      isFilled: isFilled,
                      showPlus: index == _cupsDrunk && _cupsDrunk < _totalCups,
                      fillColor: const Color(0xff61C8F5),
                      borderColor: Colors.grey.shade400,
                      borderWidth: 2,
                      radius: context.sp(1.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Glass cup widget + clipper + painter
class GlassCup extends StatelessWidget {
  final double width;
  final double height;
  final bool isFilled;
  final bool showPlus;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;

  const GlassCup({
    Key? key,
    required this.width,
    required this.height,
    required this.isFilled,
    this.showPlus = false,
    this.fillColor = const Color(0xff61C8F5),
    this.borderColor = Colors.grey,
    this.borderWidth = 2,
    this.radius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outline
          CustomPaint(
            size: Size(width, height),
            painter: GlassOutlinePainter(borderColor, borderWidth, radius),
          ),

          // clipped fill
          ClipPath(
            clipper: _GlassClipper(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: (width - borderWidth * 2) < 0 ? 0.0 : (width - borderWidth * 2),
                height: isFilled ? height * 0.55 : 0,
                margin: EdgeInsets.only(bottom: borderWidth),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(radius > borderWidth ? radius - borderWidth : radius),
                  ),
                ),
              ),
            ),
          ),
          if (showPlus)
            Icon(Icons.add, color: const Color(0xFFFFC107), size: width * 0.82),
        ],
      ),
    );
  }
}

class _GlassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Rect r = Rect.fromLTWH(0, 0, size.width, size.height);
    final double topInset = 0.0;
    final double bottomInset = size.width * 0.25;
    final Path p = Path();
    p.moveTo(r.left + topInset, r.top);
    p.lineTo(r.right - topInset, r.top);
    p.lineTo(r.right - bottomInset, r.bottom);
    p.lineTo(r.left + bottomInset, r.bottom);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class GlassOutlinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  GlassOutlinePainter(this.color, this.strokeWidth, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Rect.fromLTWH(0, 0, size.width, size.height);
    final double bottomInset = size.width * 0.15;
    final Path p = Path();
    p.moveTo(r.left, r.top + 0);
    p.lineTo(r.right, r.top + 0);
    p.lineTo(r.right - bottomInset, r.bottom);
    p.lineTo(r.left + bottomInset, r.bottom);
    p.close();

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
