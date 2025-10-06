import 'package:flutter/material.dart';
import 'models/employee_model.dart';
import 'widgets/calendar_widgets.dart';
import 'widgets/employee_list.dart';
import '../../../core/app_colors.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedScheduleId;
  Map<DateTime, List<ScheduleModel>> _employeeSchedules = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEmployeeSchedules();
  }

  void _loadEmployeeSchedules() {
    final today = DateTime.now();
    final baseDate = DateTime(today.year, today.month, 1);

    _employeeSchedules = {
      DateTime(baseDate.year, baseDate.month, 18): [
        ScheduleModel(
          id: '1',
          employeeName: 'Nutricionista',
          employeeId: 'EMP001',
          position: 'Nutricionista',
          startTime: DateTime(baseDate.year, baseDate.month, 18, 10, 0),
          endTime: DateTime(baseDate.year, baseDate.month, 18, 13, 0),
          workplace: 'Consultorio Ídola Corregimanía',
          description: 'Control semanal de los niños',
          color: const Color(0xFFFFC1E3),
          shiftType: 'morning',
          status: 'scheduled',
        ),
        ScheduleModel(
          id: '2',
          employeeName: 'Fisioterapeuta',
          employeeId: 'EMP002',
          position: 'Fisioterapeuta',
          startTime: DateTime(baseDate.year, baseDate.month, 18, 10, 0),
          endTime: DateTime(baseDate.year, baseDate.month, 18, 13, 0),
          workplace: 'Revisión de las jugadoras',
          description: 'Sesión de rehabilitación y fortalecimiento',
          color: const Color(0xFFB3E5FC),
          shiftType: 'morning',
          status: 'scheduled',
        ),
        ScheduleModel(
          id: '3',
          employeeName: 'Psicóloga',
          employeeId: 'EMP003',
          position: 'Psicóloga',
          startTime: DateTime(baseDate.year, baseDate.month, 18, 10, 0),
          endTime: DateTime(baseDate.year, baseDate.month, 18, 13, 0),
          workplace: 'Charla semanal de los niños',
          description: 'Terapia grupal y seguimiento emocional',
          color: const Color(0xFFD1C4E9),
          shiftType: 'morning',
          status: 'scheduled',
        ),
      ],
    };
    setState(() {});
  }

  List<ScheduleModel> _getEmployeeSchedulesForDay() {
    if (_selectedDay == null) return [];
    final key = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    return _employeeSchedules[key] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedScheduleId = null; // Limpiar selección al cambiar de día
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onScheduleTapped(String scheduleId) {
    setState(() {
      _selectedScheduleId = scheduleId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Calendario de horarios de empleados
          ScheduleCalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            schedulesMap: _employeeSchedules,
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
          ),

          // Lista de horarios del día seleccionado
          Expanded(
            child: EmployeeScheduleList(
              schedules: _getEmployeeSchedulesForDay(),
              selectedScheduleId: _selectedScheduleId,
              onTapSchedule: _onScheduleTapped,
            ),
          ),
        ],
      ),
    );
  }
}