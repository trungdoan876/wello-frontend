import 'package:flutter/material.dart';

class CircularCalorieIndicator extends StatelessWidget {
  const CircularCalorieIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: 0,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("0", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text("of 2,700 kcal", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () {}, child: const Text("Edit")),
      ],
    );
  }
}
