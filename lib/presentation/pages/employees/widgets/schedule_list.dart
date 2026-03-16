import 'package:flutter/material.dart';
import '../../../../data/models/schedule_model.dart';
import 'schedule_card.dart';
import 'schedule_detail_sheet.dart';

class ScheduleList extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final String? selectedScheduleId;
  final Function(String) onTapSchedule;

  const ScheduleList({
    super.key,
    required this.schedules,
    required this.selectedScheduleId,
    required this.onTapSchedule,
  });

  void _showScheduleDetail(BuildContext context, ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailSheet(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: schedules.isEmpty
          ? Container(
              key: const ValueKey('empty'),
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No hay horarios'),
            )
          : ListView.builder(
              key: ValueKey(schedules.length),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ScheduleCard(
                  schedule: schedule,
                  selected: selectedScheduleId == schedule.id,
                  onTap: () {
                    onTapSchedule(schedule.id);
                    _showScheduleDetail(context, schedule);
                  },
                );
              },
            ),
    );
  }
}
