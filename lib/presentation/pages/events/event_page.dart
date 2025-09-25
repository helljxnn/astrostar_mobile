import 'package:flutter/material.dart';
import './models/event_model.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/event_card.dart';
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
    add(
      EventModel(
        id: '1',
        title: 'Torneo Machado Sub 17',
        timeRange: '10:00-13:00',
        place: 'Cancha Cristorey',
        status: 'Programado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 2),
        color: const Color(0xFF9BE9FF),
      ),
    );

    // Clausura
    add(
      EventModel(
        id: '2',
        title: 'Clausura 2025',
        timeRange: '10:00-13:00',
        place: 'Finca Guayabal Copacabana',
        status: 'Programado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 2),
        color: const Color(0xFFB595FF),
      ),
    );

    // Taller
    add(
      EventModel(
        id: '3',
        title: 'Taller Homecenter',
        timeRange: '10:00-13:00',
        place: 'Homecenter Niquía',
        status: 'Pausado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 3),
        color: const Color(0xFFFF95E5),
      ),
    );

    // Festival
    add(
      EventModel(
        id: '4',
        title: 'Festival Deportivo',
        timeRange: '14:00-19:00',
        place: 'Estadio Municipal',
        status: 'Confirmado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 8),
        color: const Color(0xFF9BFFB6),
      ),
    );

    // Extra: Entrenamiento
    add(
      EventModel(
        id: '5',
        title: 'Festival 2025',
        timeRange: '16:00-18:00',
        place: 'Polideportivo',
        status: 'Programado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 20),
        color: const Color(0xFF9BFFB6),
      ),
    );

    // Extra: Taller
    add(
      EventModel(
        id: '6',
        title: 'Taller Técnico Avanzado',
        timeRange: '09:00-12:00',
        place: 'Coliseo Central',
        status: 'Programado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 25),
        color: const Color(0xFFFF95E5),
      ),
    );

    add(
      EventModel(
        id: '7',
        title: 'Torneo Intercolegiado',
        timeRange: '08:00-12:00',
        place: 'Cancha La Floresta',
        status: 'Pausado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 27),
        color: const Color(0xFF9BE9FF),
      ),
    );

    add(
      EventModel(
        id: '8',
        title: 'Clausura 2025',
        timeRange: '10:00-13:00',
        place: 'Finca Guayabal Copacabana',
        status: 'Programado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 27),
        color: const Color(0xFFB595FF),
      ),
    );

    add(
      EventModel(
        id: '9',
        title: 'Taller Homecenter',
        timeRange: '10:00-13:00',
        place: 'Homecenter Niquía',
        status: 'Pausado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 28),
        color: const Color(0xFFFF95E5),
      ),
    );

    add(
      EventModel(
        id: '10',
        title: 'Festival Deportivo',
        timeRange: '14:00-19:00',
        place: 'Estadio Municipal',
        status: 'Confirmado',
        date: DateTime(_focusedDay.year, _focusedDay.month, 27),
        color: const Color(0xFF9BFFB6),
      ),
    );

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Calendario en la parte superior
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              CalendarWidget(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                eventsMap: _eventsMap,
                onDaySelected: _onDaySelected,
              ),
            ],
          ),

          // Lista de eventos como bottom sheet deslizable
          DraggableScrollableSheet(
            initialChildSize: 0.5, // Tamaño inicial (40% de la pantalla)
            minChildSize: 0.5, // Tamaño mínimo al contraer
            maxChildSize: 0.85, // Tamaño máximo al expandir
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Indicador de arrastre
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Título de la sección
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        'Eventos del día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    // Lista de eventos
                    Expanded(
                      child: events.isEmpty
                          ? Center(
                              child: Text(
                                'No hay eventos para este día',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return EventCard(
                                  event: event,
                                  selected: _selectedEventId == event.id,
                                  onTap: () => _onTapEvent(event.id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
