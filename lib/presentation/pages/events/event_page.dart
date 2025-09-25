import 'package:flutter/material.dart';
import './models/event_model.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/event_list.dart';
import '../../../../core/app_colors.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedEventId;

  late Map<DateTime, List<EventModel>> _eventsMap;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _eventsMap = _buildDummyEvents();
  }

  Map<DateTime, List<EventModel>> _buildDummyEvents() {
    final map = <DateTime, List<EventModel>>{};
    void add(EventModel e) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }

    // Torneo
    add(EventModel(
      id: '1',
      title: 'Torneo Machado Sub 17',
      timeRange: '10:00-13:00',
      place: 'Cancha Cristorey',
      status: 'Programado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 2),
      color: const Color(0xFF9BE9FF),
    ));

    // Clausura
    add(EventModel(
      id: '2',
      title: 'Clausura 2025',
      timeRange: '10:00-13:00',
      place: 'Finca Guayabal Copacabana',
      status: 'Programado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 2),
      color: const Color(0xFFB595FF),
    ));

    // Taller
    add(EventModel(
      id: '3',
      title: 'Taller Homecenter',
      timeRange: '10:00-13:00',
      place: 'Homecenter Niquía',
      status: 'Pausado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 3),
      color: const Color(0xFFFF95E5),
    ));

    // Festival
    add(EventModel(
      id: '4',
      title: 'Festival Deportivo',
      timeRange: '14:00-19:00',
      place: 'Estadio Municipal',
      status: 'Confirmado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 8),
      color: const Color(0xFF9BFFB6),
    ));

    // Extra: Entrenamiento
    add(EventModel(
      id: '5',
      title: 'Festival 2025',
      timeRange: '16:00-18:00',
      place: 'Polideportivo',
      status: 'Programado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 20),
      color: const Color(0xFF9BFFB6),
    ));

    // Extra: Taller
    add(EventModel(
      id: '6',
      title: 'Taller Técnico Avanzado',
      timeRange: '09:00-12:00',
      place: 'Coliseo Central',
      status: 'Programado',
      date: DateTime(_focusedDay.year, _focusedDay.month, 25),
      color: const Color(0xFFFF95E5),
    ));

    return map;
  }

  List<EventModel> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsMap[key] ?? [];
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = DateTime(selected.year, selected.month, selected.day);
      _focusedDay = focused;
      _selectedEventId = null;
    });
  }

  void _onTapEvent(String id) {
    setState(() {
      _selectedEventId = (_selectedEventId == id) ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _selectedDay != null ? _eventsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🎨 Título con animación
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                'Calendario de eventos',
                key: ValueKey(_focusedDay.month),
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 📅 Calendario
            CalendarWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              eventsMap: _eventsMap,
              onDaySelected: _onDaySelected,
            ),

            const SizedBox(height: 6),

            // Divider tipo pill
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 12),

            // 📌 Lista de eventos con animación
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: events.isNotEmpty
                    ? EventList(
                        key: ValueKey(_selectedDay),
                        events: events.cast<EventModel>(),
                        selectedEventId: _selectedEventId,
                        onTapEvent: _onTapEvent,
                      )
                    : Center(
                        key: ValueKey("empty"),
                        child: Text(
                          "No hay eventos este día",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
