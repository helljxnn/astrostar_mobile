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
              _chevronButton(context, Icons.chevron_left, () {}),
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

          // Calendario + degradé
          Stack(
            children: [
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
                  markerDecoration:
                      const BoxDecoration(), // sin marker por defecto
                ),
                calendarBuilders: CalendarBuilders<EventModel>(
                  // Día actual (hoy)
                  todayBuilder: (context, date, _) {
                    return Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  // Día seleccionado
                  selectedBuilder: (context, date, _) {
                    return Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  // Marcadores de eventos
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
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
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: dots,
                      ),
                    );
                  },
                ),
              ),

              // Degradé inferior para tapar la raya
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 40, // un poco más alto para suavizar la transición
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0), // transparente arriba
                        Colors.white, // sólido abajo
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chevronButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
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
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[month];
  }
}
