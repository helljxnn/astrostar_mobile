import 'package:flutter/material.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/schedule_service.dart';
import 'widgets/calendar_widgets.dart';
import 'widgets/employee_list.dart';

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
  bool _showFilters = false;
  final List<_PositionFilter> _positionFilters = const [
    _PositionFilter(
      label: 'Todos',
      color: Color(0xFF94A3B8),
      icon: Icons.filter_alt,
    ),
    _PositionFilter(
      label: 'Entrenador',
      color: Color(0xFF10B981),
      icon: Icons.fitness_center,
    ),
    _PositionFilter(
      label: 'Nutricionista',
      color: Color(0xFF0EA5E9),
      icon: Icons.restaurant,
    ),
    _PositionFilter(
      label: 'Psicóloga',
      color: Color(0xFFEC4899),
      icon: Icons.psychology,
    ),
    _PositionFilter(
      label: 'Fisioterapeuta',
      color: Color(0xFF8B5CF6),
      icon: Icons.health_and_safety,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
    return schedule.position.toLowerCase().contains(
      _activePositionFilter.toLowerCase(),
    );
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

  Widget _buildFilterPanel() {
    return Material(
      elevation: 14,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por cargo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _showFilters = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _positionFilters.map((option) {
                final isSelected = _activePositionFilter == option.label;
                return FilterChip(
                  avatar: Icon(
                    option.icon,
                    size: 16,
                    color: isSelected
                        ? option.color
                        : option.color.withOpacity(0.6),
                  ),
                  label: Text(option.label),
                  selected: isSelected,
                  selectedColor: option.color.withOpacity(0.2),
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? option.color
                          : option.color.withOpacity(0.45),
                      width: 1.3,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? option.color : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onSelected: (_) {
                    if (_activePositionFilter != option.label) {
                      _setPositionFilter(option.label);
                    } else {
                      _setPositionFilter('Todos');
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading) const LinearProgressIndicator(minHeight: 3),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: AppColors.alertErrorColor.withOpacity(0.3),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.alertTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ScheduleCalendarWidget(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                schedulesMap: _visibleSchedules,
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    EmployeeScheduleList(
                      schedules: _getEmployeeSchedulesForDay(),
                      selectedScheduleId: _selectedScheduleId,
                      onTapSchedule: _onScheduleTapped,
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (_errorMessage != null && !_isLoading)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertWarningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'No se pudieron cargar los horarios, intenta nuevamente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'filterBtn',
                  backgroundColor: AppColors.primaryPurple,
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  child: const Icon(Icons.filter_alt, color: Colors.white),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      axisAlignment: 1,
                      sizeFactor: animation,
                      child: child,
                    );
                  },
                  child: _showFilters
                      ? Padding(
                          key: const ValueKey('filterPanel'),
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildFilterPanel(),
                        )
                      : const SizedBox.shrink(key: ValueKey('emptyFilter')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionFilter {
  final String label;
  final Color color;
  final IconData icon;

  const _PositionFilter({
    required this.label,
    required this.color,
    required this.icon,
  });
}
