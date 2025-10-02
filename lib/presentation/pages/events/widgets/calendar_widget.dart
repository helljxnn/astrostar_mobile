import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../../../../core/app_colors.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<EventModel>> eventsMap;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged; // Agregamos esta función

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsMap,
    required this.onDaySelected,
    required this.onPageChanged, // Requerido en el constructor
  });

  List<EventModel> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return eventsMap[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 0),
      child: Column(
        children: [
          // Header (title centered y botones)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón mes anterior
              _chevronButton(
                context,
                Icons.chevron_left,
                () => onPageChanged(
                  DateTime(focusedDay.year, focusedDay.month - 1),
                ),
              ),
              Column(
                children: [
                  Text(
                    _monthName(focusedDay.month),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${focusedDay.year}",
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              // Botón mes siguiente
              _chevronButton(
                context,
                Icons.chevron_right,
                () => onPageChanged(
                  DateTime(focusedDay.year, focusedDay.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15), // Aumentado de 12 a 20
          // Calendario + degradé
          Stack(
            children: [
              TableCalendar<EventModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                locale: 'es', // Cambiado de 'es_ES' a 'es'
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: onDaySelected,
                onPageChanged: onPageChanged,
                eventLoader: _eventsForDay,
                headerVisible: false,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekHeight: 40,
                rowHeight: 43,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                  weekendStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                  weekendTextStyle: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                  outsideTextStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  markerDecoration: const BoxDecoration(),
                ),
                calendarBuilders: CalendarBuilders<EventModel>(
                  // Día actual (hoy)
                  todayBuilder: (context, date, _) {
                    return Center(
                      child: Container(
                        width: 22,
                        height: 22,
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
                        width: 22,
                        height: 22,
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

              // Degradé inferior sutil para suavizar la transición
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height:
                    15, // Reducido significativamente para no interferir con la selección
                child: IgnorePointer(
                  // Permite que los toques pasen a través del gradiente
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(
                            alpha: 0.0,
                          ), // transparente arriba
                          Colors.white.withValues(
                            alpha: 0.8,
                          ), // menos opaco abajo
                        ],
                      ),
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
