import 'package:flutter/material.dart';

class AnimatedProgressCircle extends StatelessWidget {
  final double percentage; // 0.0 a 1.0 (por ejemplo, 0.95 = 95%)
  final Color color;
  final String label;

  const AnimatedProgressCircle({
    super.key,
    required this.percentage,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                color: color,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
