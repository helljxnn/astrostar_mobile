import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './models/event_model.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/event_list.dart';
import '../../../core/app_colors.dart';
import '../../../blocs/event/event_bloc.dart';
import '../../../blocs/event/event_event.dart';
import '../../../blocs/event/event_state.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedEventId;
  Map<DateTime, List<EventModel>> _eventsMap = {};
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    // NO cargar eventos automáticamente para evitar bloqueos
    // El usuario puede hacer pull-to-refresh o presionar un botón para cargar
  }

  Map<DateTime, List<EventModel>> _buildEventsMap(List<EventModel> events) {
    final map = <DateTime, List<EventModel>>{};
    for (var event in events) {
      final key = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(key, () => []).add(event);
    }
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

  Widget _buildStatusBanner(EventState state) {
    if (state is EventLoading && !_hasLoadedOnce) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.blue[50],
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargando eventos...',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (state is EventError) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.orange[50],
        child: Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se pudo conectar al servidor',
                style: TextStyle(color: Colors.orange[700], fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => context.read<EventBloc>().add(LoadEvents()),
              child: Text('Reintentar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    // Mostrar botón para cargar eventos si no se han cargado
    if (state is EventInitial && !_hasLoadedOnce) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.blue[50],
        child: Row(
          children: [
            Icon(Icons.cloud_download, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Eventos no cargados',
                style: TextStyle(color: Colors.blue[700], fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () => context.read<EventBloc>().add(LoadEvents()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text('Cargar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<EventBloc, EventState>(
          listener: (context, state) {
            if (state is EventLoaded) {
              setState(() {
                _hasLoadedOnce = true;
                try {
                  final apiEvents = state.events;
                  final events = apiEvents
                      .map((e) => EventModel.fromApiModel(e))
                      .toList();
                  _eventsMap = _buildEventsMap(events);
                } catch (e) {
                  _eventsMap = {};
                }
              });
            }
          },
          builder: (context, state) {
            final eventsForSelectedDay = _selectedDay != null
                ? _eventsForDay(_selectedDay!)
                : <EventModel>[];

            return Column(
              children: [
                _buildStatusBanner(state),
                const SizedBox(height: 12),
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
                CalendarWidget(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  eventsMap: _eventsMap,
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: eventsForSelectedDay.isNotEmpty
                        ? EventList(
                            key: ValueKey(_selectedDay),
                            events: eventsForSelectedDay,
                            selectedEventId: _selectedEventId,
                            onTapEvent: _onTapEvent,
                          )
                        : Center(
                            key: const ValueKey("empty"),
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
            );
          },
        ),
      ),
    );
  }
}
