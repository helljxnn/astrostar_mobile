import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final EventRepository _eventRepository = EventRepository();
  
  Map<DateTime, List<EventApiModel>> _eventsByDate = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _eventRepository.getEvents();
      setState(() {
        _eventsByDate = _groupEventsByDate(events);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar eventos: $e';
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<EventApiModel>> _groupEventsByDate(List<EventApiModel> events) {
    final Map<DateTime, List<EventApiModel>> grouped = {};
    
    for (var event in events) {
      // Solo mostrar eventos publicados
      if (!event.publish) continue;
      
      // Agrupar por fecha de inicio
      final date = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }
    
    return grouped;
  }

  List<EventApiModel> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDate[key] ?? [];
  }

  void _showEventDetails(EventApiModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventos = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.2,
                      minChildSize: 0.1,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black26,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 4,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Expanded(
                                child: eventos.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No hay eventos para este día",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: scrollController,
                                        itemCount: eventos.length,
                                        itemBuilder: (context, index) {
                                          final event = eventos[index];
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: _getStatusColor(event.status),
                                                child: const Icon(
                                                  Icons.event,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              title: Text(
                                                event.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${event.startTime} - ${event.endTime}'),
                                                  Text(
                                                    event.location,
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              trailing: Chip(
                                                label: Text(
                                                  event.status,
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                backgroundColor: _getStatusColor(event.status).withValues(alpha: 0.2),
                                              ),
                                              onTap: () => _showEventDetails(event),
                                            ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Programado':
        return Colors.blue;
      case 'Finalizado':
        return Colors.grey;
      case 'Cancelado':
        return Colors.red;
      case 'Pausado':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }
}

class EventDetailsSheet extends StatelessWidget {
  final EventApiModel event;

  const EventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (event.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 64),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(event.status),
                      backgroundColor: _getStatusColor(event.status).withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const Text(
                        'Descripción',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(event.description!),
                      const SizedBox(height: 16),
                    ],
                    _buildInfoRow(Icons.calendar_today, 'Fecha de inicio', dateFormat.format(event.startDate)),
                    _buildInfoRow(Icons.calendar_today, 'Fecha de fin', dateFormat.format(event.endDate)),
                    _buildInfoRow(Icons.access_time, 'Horario', '${event.startTime} - ${event.endTime}'),
                    _buildInfoRow(Icons.location_on, 'Ubicación', event.location),
                    _buildInfoRow(Icons.phone, 'Teléfono', event.phone),
                    if (event.category != null)
                      _buildInfoRow(Icons.category, 'Categoría', event.category!.name),
                    if (event.type != null)
                      _buildInfoRow(Icons.label, 'Tipo', event.type!.name),
                    if (event.sponsors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Patrocinadores',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...event.sponsors.map((sponsor) => ListTile(
                        leading: sponsor.sponsor.logoUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(sponsor.sponsor.logoUrl!),
                              )
                            : const CircleAvatar(child: Icon(Icons.business)),
                        title: Text(sponsor.sponsor.name),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Programado':
        return Colors.blue;
      case 'Finalizado':
        return Colors.grey;
      case 'Cancelado':
        return Colors.red;
      case 'Pausado':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }
}
