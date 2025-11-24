import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class HeightSlider extends StatefulWidget {
  final double height;                 // giá trị ban đầu
  final Function(double) onChanged;    // callback để trả kết quả

  const HeightSlider({
    super.key,
    required this.height,
    required this.onChanged,
  });

  @override
  State<HeightSlider> createState() => _HeightSliderState();
}

class _HeightSliderState extends State<HeightSlider> {
  late double _value; // giá trị thay đổi bên trong widget

  @override
  void initState() {
    super.initState();
    _value = widget.height; // gán giá trị ban đầu
  }

  void updateValue(double newValue) {
    setState(() => _value = newValue.clamp(120, 220));
    widget.onChanged(_value); // trả về cha
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ----- TITLE + CURRENT HEIGHT BOX -----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Chiều cao",
              style: GoogleFonts.baloo2(
                fontSize: context.sp(7),
                fontWeight: FontWeight.w900,
                color: const Color(0xffF8BD17),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.02),
                vertical: context.h(0.0),
              ),
              decoration: BoxDecoration(
                color: const Color(0xffF8BF15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("cm",
                  style: GoogleFonts.baloo2(
                  fontSize: context.sp(6),
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 252, 252, 252),
                ),
                  ),
                ],
              ),
            ),
          ],
        ),

        //SizedBox(height: context.h(0.015)),

        // ----- HEIGHT NUMBER ABOVE SLIDER -----
        Center(
          child: Text(
            _value.toInt().toString(),
            style: GoogleFonts.baloo2(
              fontSize: context.sp(8),
              fontWeight: FontWeight.w900,
              color: Colors.amber,
            ),
          ),
        ),

        // ----- BUTTONS + SLIDER -----
        Row(
          children: [
            // Minus button
           GestureDetector(
              onTap: () => updateValue(_value - 1),
              child: Container(
             //   padding: EdgeInsets.all(context.w(0.02)),
                child: Icon(
                  Icons.remove,
                  color: const Color(0xffF8BF15),
                  size: context.w(0.11),   // 🔥 responsive
                ),
              ),
            ),

           // SizedBox(width: context.w(0.02)),

            // Slider
            Expanded(
              child: Slider(
                value: _value,
                min: 120,
                max: 220,
                activeColor: Colors.amber,
                inactiveColor: Colors.grey.shade300,
                onChanged: (v) => updateValue(v),
              ),
            ),

          //  SizedBox(width: context.w(0.02)),

            // Plus button
           GestureDetector(
              onTap: () => updateValue(_value + 1),
              child: Container(
                //padding: EdgeInsets.all(context.w(0.02)),
                child: Icon(
                  Icons.add,
                  color: const Color(0xffF8BF15),
                  size: context.w(0.1),    // 🔥 responsive, lớn hơn nút trừ
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
