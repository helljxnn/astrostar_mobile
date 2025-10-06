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
      final key = DateTime(
        e.startDate.year,
        e.startDate.month,
        e.startDate.day,
      );
      map.putIfAbsent(key, () => []).add(e);
    }

    // Torneo Machado
    add(
      EventModel(
        id: '1',
        title: 'Torneo Machado Sub 17',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 2),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 2),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        place: 'Cancha Cristorey',
        status: 'Programado',
        category: 'Torneo',
        sponsors: ['Nike', 'Gatorade', 'Adidas'],
        color: const Color(0xFF9BE9FF),
      ),
    );

    // Clausura
    add(
      EventModel(
        id: '2',
        title: 'Clausura 2025',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 2),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 2),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        place: 'Finca Guayabal Copacabana',
        status: 'Programado',
        category: 'Evento Social',
        sponsors: [
          'Pepsi',
          'Coordinadora',
          'Avianca',
          'Samsung',
          'Bancolombia',
        ],
        color: const Color(0xFFB595FF),
      ),
    );

    // Taller
    add(
      EventModel(
        id: '3',
        title: 'Taller Homecenter',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 3),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 3),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        place: 'Homecenter Niquía',
        status: 'Pausado',
        category: 'Capacitación',
        sponsors: ['Homecenter', 'Corona'],
        color: const Color(0xFFFF95E5),
      ),
    );

    // Festival Deportivo
    add(
      EventModel(
        id: '4',
        title: 'Festival Deportivo',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 8),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 8),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        place: 'Estadio Municipal',
        status: 'Confirmado',
        category: 'Festival',
        sponsors: ['Powerade', 'Under Armour', 'Municipio'],
        color: const Color(0xFF9BFFB6),
      ),
    );

    // Festival 2025
    add(
      EventModel(
        id: '5',
        title: 'Festival 2025',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 20),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 20),
        startTime: const TimeOfDay(hour: 16, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
        place: 'Polideportivo',
        status: 'Programado',
        category: 'Festival',
        sponsors: ['Coca-Cola', 'Bancolombia'],
        color: const Color(0xFF9BFFB6),
      ),
    );

    // Taller Técnico
    add(
      EventModel(
        id: '6',
        title: 'Taller Homecenter',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 25),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        place: 'Coliseo Central',
        status: 'Programado',
        category: 'Torneo',
        sponsors: ['Adidas', 'Natipan', 'Homecenter'],
        color: const Color(0xFFFF95E5),
      ),
    );

    // Torneo Intercolegiado
    add(
      EventModel(
        id: '7',
        title: 'Torneo Intercolegiado',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        place: 'Cancha La Floresta',
        status: 'Pausado',
        category: 'Torneo',
        sponsors: ['Colanta', 'Homecenter'],
        color: const Color(0xFF9BE9FF),
      ),
    );

    // Segunda Clausura
    add(
      EventModel(
        id: '8',
        title: 'Clausura 2025',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        place: 'Finca Guayabal Copacabana',
        status: 'Programado',
        category: 'Evento Social',
        sponsors: ['Samsung', 'Avianca'],
        color: const Color(0xFFB595FF),
      ),
    );

    // Segundo Taller
    add(
      EventModel(
        id: '9',
        title: 'Taller Homecenter',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 28),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 28),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        place: 'Homecenter Niquía',
        status: 'Pausado',
        category: 'Capacitación',
        sponsors: ['Homecenter', 'Pintuco'],
        color: const Color(0xFFFF95E5),
      ),
    );

    // Festival Final
    add(
      EventModel(
        id: '10',
        title: 'Festival Deportivo',
        startDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        endDate: DateTime(_focusedDay.year, _focusedDay.month, 27),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        place: 'Estadio Municipal',
        status: 'Programado',
        category: 'Festival',
        sponsors: ['Puma', 'Red Bull', 'Municipio'],
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

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _selectedDay != null ? _eventsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              CalendarWidget(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                eventsMap: _eventsMap,
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.50, // Reducido para menos solapamiento
            minChildSize: 0.50, // Tamaño mínimo al contraer
            maxChildSize: 0.88, // Tamaño máximo al expandir
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
