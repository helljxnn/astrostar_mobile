import 'package:flutter/material.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';
import '../../../core/app_colors.dart';
import '../../../core/api_service.dart';
import '../../../data/services/schedule_service.dart';
import 'widgets/schedule_calendar_widget.dart';
import 'widgets/schedule_list.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedScheduleId;
  final ScheduleService _scheduleService = ScheduleService();
  Map<DateTime, List<ScheduleModel>> _employeeSchedules = {};
  Map<DateTime, List<ScheduleModel>> _visibleSchedules = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _activePositionFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _fetchEmployeeSchedules();
  }

  Future<void> _fetchEmployeeSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _scheduleService.fetchSchedules(limit: 100);
      final grouped = _groupSchedulesByDate(schedules);
      setState(() {
        _employeeSchedules = grouped;
      });
      _applyFilter(resetSelected: true);
    } on TokenExpiredException {
      // Token expirado - redirigir al login
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _employeeSchedules = {};
        _visibleSchedules = {};
        _selectedDay = _focusedDay;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<DateTime, List<ScheduleModel>> _groupSchedulesByDate(
    List<ScheduleModel> schedules,
  ) {
    final grouped = <DateTime, List<ScheduleModel>>{};
    final limitDate = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    ).add(const Duration(days: 90));

    for (final schedule in schedules) {
      for (final occurrence in _expandRecurrenceDates(schedule, limitDate)) {
        grouped.putIfAbsent(occurrence, () => []).add(schedule);
      }
    }

    for (final daySchedules in grouped.values) {
      daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  DateTime _determineInitialSelectedDay(
    Map<DateTime, List<ScheduleModel>> grouped,
  ) {
    if (grouped.isEmpty) return _focusedDay;

    final sortedDays = grouped.keys.toList()..sort();
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (grouped.containsKey(normalizedToday)) {
      return normalizedToday;
    }

    return sortedDays.first;
  }

  List<ScheduleModel> _getEmployeeSchedulesForDay() {
    if (_selectedDay == null) return [];
    final key = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    return _visibleSchedules[key] ?? [];
  }

  bool _matchesFilter(ScheduleModel schedule) {
    if (_activePositionFilter == 'Todos') return true;
    if (_activePositionFilter == 'Entrenador') {
      return _normalizeRole(schedule.position) == 'entrenador';
    }
    if (_activePositionFilter == 'Profesional en Salud') {
      final normalized = _normalizeRole(schedule.position);
      return normalized == 'profesionalsalud' ||
          normalized == 'profesionaldelasalud' ||
          normalized == 'profesionaldesalud' ||
          normalized == 'fisioterapeuta' ||
          normalized == 'fisioterapia' ||
          normalized == 'nutricionista' ||
          normalized == 'nutricion' ||
          normalized == 'psicologa' ||
          normalized == 'psicologo' ||
          normalized == 'psicologia';
    }
    return schedule.position.toLowerCase().contains(
      _activePositionFilter.toLowerCase(),
    );
  }

  String _normalizeRole(String cargo) {
    return cargo
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  void _applyFilter({bool resetSelected = false}) {
    final filtered = <DateTime, List<ScheduleModel>>{};
    for (final entry in _employeeSchedules.entries) {
      final items = entry.value.where(_matchesFilter).toList();
      if (items.isNotEmpty) {
        filtered[entry.key] = items;
      }
    }

    setState(() {
      _visibleSchedules = filtered;
      if (resetSelected) {
        final sourceMap = filtered.isNotEmpty ? filtered : _employeeSchedules;
        final newDay = _determineInitialSelectedDay(sourceMap);
        _selectedDay = newDay;
        _focusedDay = newDay;
      } else if (_selectedDay != null && !filtered.containsKey(_selectedDay)) {
        final fallbackDay = filtered.isNotEmpty
            ? filtered.keys.first
            : _focusedDay;
        _selectedDay = fallbackDay;
        _focusedDay = fallbackDay;
      }
    });
  }

  void _setPositionFilter(String position) {
    setState(() {
      _activePositionFilter = position;
    });
    _applyFilter(resetSelected: true);
  }

  void _showFilterSheet(BuildContext context) {
    const filters = ['Todos', 'Entrenador', 'Profesional en Salud'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtrar por cargo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters.map((pos) {
                final isSelected = _activePositionFilter == pos;
                return GestureDetector(
                  onTap: () {
                    _setPositionFilter(pos);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      pos,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _expandRecurrenceDates(
    ScheduleModel schedule,
    DateTime limit,
  ) {
    final occurrences = <DateTime>[];
    final base = DateTime(
      schedule.scheduleDate.year,
      schedule.scheduleDate.month,
      schedule.scheduleDate.day,
    );
    occurrences.add(base);

    if (schedule.recurrence == 'no') {
      return occurrences;
    }

    DateTime current = base;
    final seen = <DateTime>{base};

    while (true) {
      final next = _nextRecurringDate(schedule, current);
      if (next == null || next.isAfter(limit) || seen.contains(next)) break;
      occurrences.add(next);
      seen.add(next);
      current = next;
    }

    return occurrences;
  }

  DateTime? _nextRecurringDate(ScheduleModel schedule, DateTime current) {
    switch (schedule.recurrence) {
      case 'dia':
        return current.add(const Duration(days: 1));
      case 'semana':
        return current.add(const Duration(days: 7));
      case 'mes':
        return DateTime(current.year, current.month + 1, current.day);
      case 'anio':
        return DateTime(current.year + 1, current.month, current.day);
      case 'laboral':
        DateTime next = current.add(const Duration(days: 1));
        while (next.weekday == DateTime.saturday ||
            next.weekday == DateTime.sunday) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case 'personalizado':
        final weekdays = schedule.customWeekdayNumbers;
        if (weekdays == null || weekdays.isEmpty) {
          return current.add(const Duration(days: 7));
        }
        final currentWeekday = current.weekday;
        final following = weekdays.firstWhere(
          (day) => day > currentWeekday,
          orElse: () => weekdays.first,
        );
        final offset = following > currentWeekday
            ? following - currentWeekday
            : (7 - currentWeekday + following);
        final daysToAdd = offset == 0 ? 7 : offset;
        return current.add(Duration(days: daysToAdd));
      default:
        return null;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedScheduleId = null;
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

  Widget _buildStatusBanner() {
    if (_isLoading && _visibleSchedules.isEmpty) {
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
            Text('Cargando horarios...'),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = _getEmployeeSchedulesForDay();

    if (_isLoading && _visibleSchedules.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _visibleSchedules.isEmpty) {
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
                  'Error al cargar horarios',
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
                  onPressed: _fetchEmployeeSchedules,
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
        onPressed: _fetchEmployeeSchedules,
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
                'Horario',
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
            ScheduleCalendarWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              schedulesMap: _visibleSchedules,
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
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
            // Botón de filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _activePositionFilter != 'Todos'
                            ? AppColors.primaryPurple
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 22,
                        color: _activePositionFilter != 'Todos'
                            ? Colors.white
                            : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  if (_activePositionFilter != 'Todos') ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _activePositionFilter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _setPositionFilter('Todos'),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: schedules.isNotEmpty
                    ? ScheduleList(
                        key: ValueKey(_selectedDay),
                        schedules: schedules,
                        selectedScheduleId: _selectedScheduleId,
                        onTapSchedule: _onScheduleTapped,
                      )
                    : Center(
                        key: const ValueKey("empty"),
                        child: Text(
                          "No hay horarios para este día",
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
