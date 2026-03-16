import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool selected;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.selected = false,
    required this.onTap,
  });

  Color _getStatusColor() {
    final status = appointment['status'] as String;
    switch (status.toLowerCase()) {
      case 'programado':
        return Colors.green;
      case 'cumplido':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '$hour:$minute $period';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final bg = statusColor.withValues(alpha: 0.12);
    final status = appointment['status'] as String;
    final startTime = _formatTime(appointment['startTime'] ?? '');
    final endTime = _formatTime(appointment['endTime'] ?? '');
    final timeRange = '$startTime - $endTime';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.07 : 0.03),
            blurRadius: selected ? 12 : 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // colored left indicator
                Container(
                  width: 6,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                // content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // time + small colored dot
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeRange,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appointment['specialty'] ?? 'Cita',
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.02,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Con ${appointment['specialistName'] ?? 'Especialista'}',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                // status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
