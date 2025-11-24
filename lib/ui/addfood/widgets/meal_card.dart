import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  const MealCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.green),
          onPressed: onAdd,
        ),
      ),
    );
  }
}
