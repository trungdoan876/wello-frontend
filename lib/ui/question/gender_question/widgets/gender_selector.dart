import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/data/models/question.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class GenderSelector extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;
  final List<QuestionOption> options;

  const GenderSelector({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.options,
  });

  IconData _getIconForGender(String answer) {
    switch (answer) {
      case 'MALE':
        return Icons.male;
      case 'FEMALE':
        return Icons.female;
      case 'OTHER':
        return Icons.transgender;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.w(0.03),   // khoảng cách ngang
      runSpacing: context.h(0.025), // khoảng cách khi xuống hàng
      children: options.map((option) {
        return genderItem(
          context,
          option.answer,
          option.moTa,
          _getIconForGender(option.answer),
        );
      }).toList(),
    );
  }

  Widget genderItem(
      BuildContext context, String value, String label, IconData icon) {
    final bool isActive = (value == selected);

    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: context.w(0.39),                // responsive width
        padding: EdgeInsets.all(context.w(0.01)), // responsive padding
        decoration: BoxDecoration(
          gradient: isActive 
              ? const LinearGradient(
                  colors: [Color(0xffF8BD17), Color(0xffF4D205)], // từ vàng sang cam
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null, // hoặc màu mặc định
          color: isActive ? null : Colors.grey.shade300, // màu nền khi không active
          borderRadius: BorderRadius.circular(context.w(0.04)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: context.w(0.23), // responsive icon size
              color: Colors.white,
            ),
           // SizedBox(height: context.h(0.01)),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(7), // responsive text
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

