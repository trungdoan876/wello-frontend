import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../meal_selection/meal_selection_screen.dart';

class QAData {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  // Mỗi item có thể khai báo gradient riêng (start/end)
  final Color? gradStart;
  final Color? gradEnd;
  const QAData(
    this.key,
    this.label,
    this.icon,
    this.color, {
    this.gradStart,
    this.gradEnd,
  });
}

class QuickActionsPanel extends StatelessWidget {
  final void Function(String key) onAction;
  const QuickActionsPanel({super.key, required this.onAction});

  void _navigateToMealSelection(
    BuildContext context,
    String key,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MealSelectionScreen(mealType: key, mealTitle: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <QAData>[
      const QAData(
        'tap_luyen',
        'Tập luyện',
        Icons.directions_bike,
        Color(0xFFFD6C6C),
        gradStart: Color(0xFFEC7E7E),
        gradEnd: Color(0xFFFCA6A6),
      ),
      const QAData(
        'bua_phu',
        'Bữa phụ',
        Icons.fastfood,
        Color(0xFF5CA7FF),
        gradStart: Color(0xFF3A87D0),
        gradEnd: Color(0xFFA1C6E8),
      ),
      const QAData(
        'bua_toi',
        'Bữa tối',
        Icons.dinner_dining,
        Color(0xFF41C784),
        gradStart: Color(0xFF4CCF64),
        gradEnd: Color(0xFF86D89A),
      ),
      const QAData(
        'bua_trua',
        'Bữa trưa',
        Icons.rice_bowl,
        Color(0xFFB76DF1),
        gradStart: Color(0xFFBE72C4),
        gradEnd: Color(0xFFE3B2E6),
      ),
      const QAData(
        'bua_sang',
        'Bữa sáng',
        Icons.bakery_dining,
        Color(0xFFFF4DAA),
        gradStart: Color(0xFFFE84BF),
        gradEnd: Color(0xFFF9B4D5),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final it in items) ...[
          _QAChip(
            data: it,
            onTap: () {
              _navigateToMealSelection(context, it.key, it.label);
              onAction(it.key);
            },
          ),
          SizedBox(height: context.h(0.012)),
        ],
      ],
    );
  }
}

class _QAChip extends StatelessWidget {
  final QAData data;
  final VoidCallback onTap;
  const _QAChip({required this.data, required this.onTap});

  Color _lighten(Color c, [double t = 0.6]) {
    return Color.lerp(c, Colors.white, t) ?? c;
  }

  @override
  Widget build(BuildContext context) {
    final Color base = data.color;
    // Mỗi item có gradient riêng; nếu không có thì fallback lighten -> base
    final List<Color> gradColors = [
      data.gradStart ?? _lighten(base, 0.30),
      data.gradEnd ?? base,
    ];
    final LinearGradient sharedGradientLR = LinearGradient(
      colors: gradColors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final LinearGradient sharedGradientDiag = LinearGradient(
      colors: gradColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label pill ở trái
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.035),
                vertical: context.h(0.01),
              ),
              decoration: BoxDecoration(
                gradient: sharedGradientLR,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                data.label,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: context.w(0.018)),
            // Nút tròn icon ở phải
            Container(
              width: context.sp(12),
              height: context.sp(12),
              decoration: BoxDecoration(
                gradient: sharedGradientDiag,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(data.icon, color: Colors.white, size: context.sp(6)),
            ),
          ],
        ),
      ),
    );
  }
}

class PlusBubble extends StatelessWidget {
  final VoidCallback onTap;
  final bool open;
  const PlusBubble({super.key, required this.onTap, required this.open});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: context.sp(14),
          height: context.sp(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8BD17), Color(0xFFEBCF23)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.add, color: Colors.white, size: context.sp(8)),
            ),
          ),
        ),
      ),
    );
  }
}
