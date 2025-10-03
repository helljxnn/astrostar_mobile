// lib/presentation/pages/appointments/appointments_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/appointment_models.dart';
import 'widgets/appointment_list_sheet.dart';
import '../../../core/app_colors.dart';
import 'widgets/calendar_header.dart';
import 'widgets/schedule_appointment_form.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPage();
}

class _AppointmentsPage extends State<AppointmentsPage> {
  // --- Datos de ejemplo ---
  final Athlete _athlete1 = Athlete(id: 'ath1', name: 'Carlos Alcaraz');
  final Specialist _spec1 = Specialist(
    id: 'spec1',
    name: 'Dr. Fisioterapeuta 1',
    specialty: SpecialtyType.physiotherapy,
    schedule: 'L-V 9-17',
  );
  final Specialist _spec2 = Specialist(
    id: 'spec3',
    name: 'Dra. Nutricionista',
    specialty: SpecialtyType.nutrition,
    schedule: 'L,M 10-18',
  );

  late final List<Appointment> _allAppointments;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _allAppointments = [
      Appointment(
        id: 'c1',
        athlete: _athlete1,
        specialist: _spec1,
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        description: 'Dolor de rodilla',
      ),
      Appointment(
        id: 'c2',
        athlete: _athlete1,
        specialist: _spec2,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        description: 'Plan de alimentación',
      ),
      Appointment(
        id: 'c3',
        athlete: _athlete1,
        specialist: _spec1,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        description: 'Seguimiento lesión',
      ),
    ];
    _selectedDay = _focusedDay;
    _selectedAppointments = _getAppointmentsForDay(_selectedDay!);
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> _selectedAppointments = [];

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _allAppointments
        .where((appointment) => isSameDay(appointment.dateTime, day))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedAppointments = _getAppointmentsForDay(selectedDay);
      });
    }
  }

  void _showScheduleAppointmentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const ScheduleAppointmentForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar eliminado para liberar el espacio superior
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildCalendar(),
          AppointmentListSheet(
            selectedAppointments: _selectedAppointments,
            selectedDay: _selectedDay ?? DateTime.now(),
            onRefresh: _refreshAppointments,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleAppointmentForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agendar Cita'),
        backgroundColor: AppColors.authPrimaryLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _refreshAppointments(DateTime day) {
    setState(() {
      _selectedAppointments = _getAppointmentsForDay(day);
    });
  }

  Widget _buildCalendar() {
    return Padding(
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(context).padding.top +
            40.0, // Aumentamos el espacio superior
        left: 18.0,
        right: 18.0,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Hace que la columna ocupe solo lo necesario
        children: [
          CalendarHeader(
            focusedDay: _focusedDay,
            onLeftArrowTap: () {
              _pageController.previousPage(
                // Asumo que _pageController está inicializado
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            onRightArrowTap: () {
              _pageController.nextPage(
                // Asumo que _pageController está inicializado
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 320, // Altura fija para el calendario
            child: TableCalendar<Appointment>(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2031, 12, 31),
              focusedDay: _focusedDay,
              locale: 'es_ES',
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 42,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: _getAppointmentsForDay,
              onCalendarCreated: (controller) => _pageController = controller,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              headerVisible: false,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 11),
                weekendStyle: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(8.0),
                defaultTextStyle: const TextStyle(fontSize: 13),
                weekendTextStyle: const TextStyle(fontSize: 13),
                outsideTextStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.authPrimaryColor,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
                markerSize: 5.0,
                markerDecoration: const BoxDecoration(
                  color: AppColors.authPrimaryColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerMargin: const EdgeInsets.only(top: 8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
