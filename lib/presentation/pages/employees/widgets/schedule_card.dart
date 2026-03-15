import 'package:flutter/material.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../core/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool selected;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = schedule.roleColor.withValues(alpha: 0.12);

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
                    color: schedule.roleColor,
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
                              color: schedule.roleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            schedule.scheduleRange,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        schedule.employeeName,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.02,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        schedule.position,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                // position chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: schedule.roleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.position,
                    style: TextStyle(
                      color: schedule.roleColor,
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
