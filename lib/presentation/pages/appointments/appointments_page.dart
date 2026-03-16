import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/appointment_service.dart';
import 'widgets/appointment_card.dart';
import 'widgets/appointment_detail_sheet.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedAppointmentId;

  final AppointmentService _appointmentService = AppointmentService();
  List<Map<String, dynamic>> _allAppointments = [];
  Map<DateTime, List<Map<String, dynamic>>> _appointmentsByDate = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final result = await _appointmentService.fetchAppointments(
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _allAppointments =
              result['appointments'] as List<Map<String, dynamic>>;
          _appointmentsByDate = _groupAppointmentsByDate(_allAppointments);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _allAppointments = [];
          _appointmentsByDate = {};
          _isLoading = false;
        });
      }
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupAppointmentsByDate(
    List<Map<String, dynamic>> appointments,
  ) {
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (var appointment in appointments) {
      try {
        final dateStr = appointment['appointmentDate'] as String;
        final date = DateTime.parse(dateStr);
        final key = DateTime(date.year, date.month, date.day);

        if (grouped[key] == null) {
          grouped[key] = [];
        }
        grouped[key]!.add(appointment);
      } catch (e) {
        // Skip invalid dates
      }
    }

    return grouped;
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _appointmentsByDate[key] ?? [];
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppointmentDetailSheet(
        appointment: appointment,
        onUpdate: _loadAppointments,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'programado':
        return Colors.green;
      case 'cumplido':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBanner() {
    if (_isLoading && _appointmentsByDate.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blue[100],
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Cargando citas...'),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _selectedDay != null
        ? _getAppointmentsForDay(_selectedDay!)
        : [];

    if (_isLoading && _appointmentsByDate.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _appointmentsByDate.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar citas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAppointments,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAppointments,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                'Citas',
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
            _buildCalendar(),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: appointments.isNotEmpty
                      ? ListView.builder(
                          key: ValueKey(_selectedDay),
                          padding: const EdgeInsets.only(top: 12),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return AppointmentCard(
                              appointment: appointment,
                              selected:
                                  _selectedAppointmentId ==
                                  appointment['id'].toString(),
                              onTap: () {
                                setState(() {
                                  _selectedAppointmentId = appointment['id']
                                      .toString();
                                });
                                _showAppointmentDetails(appointment);
                              },
                            );
                          },
                        )
                      : Padding(
                          key: const ValueKey("empty"),
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No hay citas para este día",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chevronButton(Icons.chevron_left, () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                  );
                });
                _loadAppointments();
              }),
              Column(
                children: [
                  Text(
                    _monthName(_focusedDay.month),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_focusedDay.year}",
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              _chevronButton(Icons.chevron_right, () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                  );
                });
                _loadAppointments();
              }),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getAppointmentsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );
                _focusedDay = focusedDay;
                _selectedAppointmentId = null;
              });
            },
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
              cellMargin: const EdgeInsets.all(12),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final dots = events.take(3).map((e) {
                  final status =
                      (e as Map<String, dynamic>)['status'] as String;
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList();

                return Positioned(
                  bottom: 4,
                  child: Row(mainAxisSize: MainAxisSize.min, children: dots),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chevronButton(IconData icon, VoidCallback onTap) {
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
