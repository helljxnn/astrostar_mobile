import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF6C47FF), required String text, // color violeta para el principal
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shadowColor: Colors.grey.shade300,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
