import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class HeightSlider extends StatefulWidget {
  final double height;                 // giá trị ban đầu
  final Function(double) onChanged;    // callback để trả kết quả
  final String unit;
  final String label;

  const HeightSlider({
    super.key,
    required this.height,
    required this.onChanged,
    required this.unit,
    this.label = "Chiều cao",
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
              widget.label,
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
                  Text(widget.unit,
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
                  size: context.w(0.11),   // responsive
                ),
              ),
            ),

           //SizedBox(width: context.w(0.02)),

            // Slider
           Expanded(
            child: SizedBox(
          height: context.h(0.12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tính vị trí chính xác của thumb
              double min = 120.0;
              double max = 220.0;
              double percent = (_value - min) / (max - min);
              double thumbX = percent * constraints.maxWidth;

              // Giới hạn để số không bị tràn ra ngoài
              double numberWidth = 60; // Ước lượng chiều rộng của số (3 chữ số + padding)
              double left = (thumbX - numberWidth / 2).clamp(0.0, constraints.maxWidth - numberWidth);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Slider chính
                  Slider(
                    value: _value,
                    min: 120.0,
                    max: 220.0,
                    activeColor: const Color(0xffF8BD17),
                    inactiveColor: Colors.grey.shade300,
                    thumbColor: Colors.amber, // Ẩn thumb mặc định để tự làm đẹp hơn
                    onChanged: updateValue,
                  ),

                  // Số đi theo thumb
                  Positioned(
                    left: left,
                    bottom: 60, // Điều chỉnh độ cao của số
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    
                      child: Text(
                        _value.toInt().toString(),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(8),
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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

