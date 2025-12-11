import 'package:flutter/material.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';
import './employee_card.dart';

class EmployeeScheduleList extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final String? selectedScheduleId;
  final Function(String) onTapSchedule;

  const EmployeeScheduleList({
    super.key,
    required this.schedules,
    required this.selectedScheduleId,
    required this.onTapSchedule,
  });

  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher para animar el cambio de lista cuando cambie el día
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: schedules.isEmpty
          ? Container(
              key: const ValueKey('empty'),
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay horarios programados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              key: ValueKey(schedules.length), // fuerza la animación cuando cambian
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return EmployeeScheduleCard(
                  schedule: schedule,
                  selected: selectedScheduleId == schedule.id,
                  onTap: () => onTapSchedule(schedule.id),
                );
              },
            ),
    );
  }
}
