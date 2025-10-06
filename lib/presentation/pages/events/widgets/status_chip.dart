import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color _colorForStatus() {
    switch (status.toLowerCase()) {
      case 'programado':
        return AppColors.primaryPurple;
      case 'pausado':
        return AppColors.primaryPink;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
