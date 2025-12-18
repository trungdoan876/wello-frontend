// lib/ui/home/widgets/water_tracker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';

class WaterTracker extends StatelessWidget {
  const WaterTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        // Get data from provider with fallback values = 0
        final waterIntake = provider.dailySummary?.waterIntake;
        final int consumedMl = waterIntake?.consumed ?? 0;
        final int targetMl = waterIntake?.target ?? 0;
        final String targetMlString = targetMl > 0 ? '${targetMl}ml' : '0ml';
        
        // Calculate cups dynamically based on target
        const int glassSize = 250; // ml per glass
        final int totalCups = targetMl > 0 ? (targetMl / glassSize).ceil() : 6; // Default 6 if no data
        final int cupsDrunk = consumedMl > 0 ? (consumedMl / glassSize).floor() : 0;

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
                  '${consumedMl}ml/$targetMlString',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    color: const Color(0xff6177D0),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            
            // Label showing glass size
            Padding(
              padding: EdgeInsets.only(top: context.h(0.005)),
              child: Text(
                'Mỗi cốc = ${glassSize}ml',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3.5),
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            SizedBox(height: context.h(0.01)),

            // Cup row - wrap to multiple rows if needed
            Container(
              padding: EdgeInsets.all(context.w(0.02)),
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
              child: Wrap(
                spacing: context.w(0.02), // Horizontal spacing
                runSpacing: context.h(0.01), // Vertical spacing between rows
                children: List.generate(totalCups, (index) {
                  final bool isFilled = index < cupsDrunk;

                  return GestureDetector(
                    onTap: () async {
                      print('🔵 Water glass tapped! Index: $index, isFilled: $isFilled, cupsDrunk: $cupsDrunk');
                      
                      // Only allow adding water, not removing
                      if (!isFilled) {
                        print('🟡 Getting credentials...');
                        final credentials = await AuthHelper.getCredentials();
                        
                        if (credentials != null) {
                          print('🟢 Credentials found! Calling API...');
                          print('   Token: ${credentials.token}');
                          print('   UserId: ${credentials.userIdString}');
                          
                          try {
                            await provider.addWaterGlass(
                              credentials.token,
                              credentials.userIdString,
                            );
                            print('✅ Water added successfully!');
                            
                            // Show success feedback
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đã thêm 250ml nước! 💧',
                                        style: GoogleFonts.baloo2(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xff61C8F5),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            print('❌ Error adding water: $e');
                            
                            // Show error feedback
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: Không thể thêm nước'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } else {
                          print('❌ No credentials found! User not logged in?');
                        }
                      } else {
                        print('⚠️ Glass already filled, cannot add more');
                      }
                    },
                    child: SizedBox(
                      width: context.w(0.12),
                      child: GlassCup(
                        width: context.w(0.10),
                        height: context.w(0.12),
                        isFilled: isFilled,
                        showPlus: index == cupsDrunk && cupsDrunk < totalCups,
                        fillColor: const Color(0xff61C8F5),
                        borderColor: Colors.grey.shade400,
                        borderWidth: 2,
                        radius: context.sp(1.0),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
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
