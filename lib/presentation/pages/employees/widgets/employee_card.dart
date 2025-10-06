import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../../../../core/app_colors.dart';
import './employee_detail_sheet.dart';

class EmployeeScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool selected;
  final VoidCallback onTap;

  const EmployeeScheduleCard({
    super.key,
    required this.schedule,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = schedule.color.withValues(alpha: 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(color: schedule.color, width: 2)
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
          onTap: () {
            // Mostrar bottom sheet con detalles del horario
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => EmployeeScheduleDetailSheet(schedule: schedule),
            );
            // Llamar al onTap original si es necesario
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Indicador de color izquierdo
                Container(
                  width: 6,
                  height: 56,
                  decoration: BoxDecoration(
                    color: schedule.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horario + punto de color
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: schedule.color,
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
                      
                      // Nombre del empleado
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
                      
                      // Lugar de trabajo
                      Text(
                        schedule.workplace,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                // Badge del cargo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.position,
                    style: TextStyle(
                      color: schedule.color,
                      fontSize: 11,
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