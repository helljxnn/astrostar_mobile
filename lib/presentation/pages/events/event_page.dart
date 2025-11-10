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

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EventError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar eventos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<EventBloc>().add(LoadEvents()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

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
