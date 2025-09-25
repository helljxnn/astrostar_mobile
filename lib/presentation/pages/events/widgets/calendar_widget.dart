import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../../../../core/app_colors.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<EventModel>> eventsMap;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsMap,
    required this.onDaySelected,
  });

  List<EventModel> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return eventsMap[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          // Header (title centered y botones)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chevronButton(context, Icons.chevron_left, () {
                // TableCalendar internal controls not available here,
                // parent can pass focusedDay change via callback if needed.
              }),
              Column(
                children: [
                  Text(
                    "${_monthName(focusedDay.month)}",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${focusedDay.year}",
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              _chevronButton(context, Icons.chevron_right, () {}),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              onDaySelected(selected, focused);
            },
            eventLoader: _eventsForDay,
            headerVisible: false,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.muted),
              weekendStyle: TextStyle(color: AppColors.muted),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: AppColors.textDark),
              weekendTextStyle: TextStyle(color: AppColors.textDark),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(), // no default marker
            ),
            calendarBuilders: CalendarBuilders<EventModel>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                // Build up to 3 tiny dots under the day number
                final dots = events.take(3).map((e) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList();

                return Positioned(
                  bottom: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: dots,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chevronButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 22, color: AppColors.muted),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return names[month];
  }
}
