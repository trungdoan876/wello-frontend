import 'package:flutter/material.dart';

class MacroInfo extends StatelessWidget {
  const MacroInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _MacroItem(label: "Carbs", value: "0 / 329 g"),
        _MacroItem(label: "Fat", value: "0 / 73 g"),
        _MacroItem(label: "Protein", value: "0 / 165 g"),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  const _MacroItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
