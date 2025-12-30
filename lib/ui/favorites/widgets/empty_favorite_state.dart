import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class EmptyFavoriteState extends StatelessWidget {
  const EmptyFavoriteState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEBCF23);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.w(0.06)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(4)),
            border: Border.all(
              color: const Color(0xFFFFC107).withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.06),
            vertical: context.h(0.03),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero illustration
              Container(
                width: context.w(0.28),
                height: context.w(0.28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.95), accent.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.restaurant_menu,
                  size: context.sp(14),
                  color: Colors.white,
                ),
              ),

              SizedBox(height: context.h(0.025)),

              // Title
              Text(
                'Gợi ý thực phẩm cho bạn',
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(7),
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.3,
                ),
              ),

              SizedBox(height: context.h(0.008)),

              // Subtitle
              Text(
                'Khám phá thực phẩm phù hợp với mục tiêu dinh dưỡng của bạn.',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: context.sp(4.2),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              SizedBox(height: context.h(0.02)),

              // Section label
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sp(3.5),
                  vertical: context.sp(1.6),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(context.sp(3)),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withOpacity(0.35),
                  ),
                ),
                child: Text(
                  'Gợi ý nổi bật hôm nay',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.6),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE68F00),
                  ),
                ),
              ),

              SizedBox(height: context.h(0.018)),

              // Chips list
              Wrap(
                spacing: context.sp(2.5),
                runSpacing: context.sp(2),
                children: [
                  'Hạnh nhân',
                  'Măng tây',
                  'Dừa',
                  'Gừng',
                  'Mật ong',
                ].map((label) => _chip(context, label)).toList(),
              ),

              SizedBox(height: context.h(0.028)),

              // Explore button (visual only)
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.explore_rounded, size: context.sp(5)),
                label: Text(
                  'Xem gợi ý',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.08),
                    vertical: context.h(0.015),
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.sp(3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(3.2),
        vertical: context.sp(1.4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.15),
        borderRadius: BorderRadius.circular(context.sp(3)),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: context.sp(3.8),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
