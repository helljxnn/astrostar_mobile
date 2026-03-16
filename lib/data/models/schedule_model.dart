import 'dart:convert';

import 'package:flutter/material.dart';

/// Modelo para horarios de empleados
class ScheduleModel {
  final String id;
  final String employeeName;
  final String employeeId;
  final String position;
  final DateTime startTime;
  final DateTime endTime;
  final String workplace;
  final String? description;
  final Color color;
  final String recurrence;
  final String timezone;
  final String? customRecurrence;
  // Campos adicionales opcionales
  final String? shiftType;
  final String? department;
  final List<String>? tasks;

  ScheduleModel({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.position,
    required this.startTime,
    required this.endTime,
    required this.workplace,
    this.description,
    required this.color,
    required this.recurrence,
    required this.timezone,
    this.shiftType,
    this.department,
    this.customRecurrence,
    this.tasks,
  });

  // ==================== GETTERS ====================

  /// Duración del turno en horas
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60;
  }

  /// Duración del turno en minutos
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Rango de horario formateado (HH:mm - HH:mm)
  String get scheduleRange {
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);
    return '$start - $end';
  }

  /// Fecha del horario
  DateTime get scheduleDate =>
      DateTime(startTime.year, startTime.month, startTime.day);

  /// Día de la semana (Lunes, Martes, etc.)
  String get dayOfWeek {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[startTime.weekday - 1];
  }

  /// Fecha formateada (dd/MM/yyyy)
  String get formattedDate => _formatDate(scheduleDate);

  /// Verifica si el horario es de hoy
  bool get isToday {
    final now = DateTime.now();
    return scheduleDate.year == now.year &&
        scheduleDate.month == now.month &&
        scheduleDate.day == now.day;
  }

  /// Verifica si el horario ya pasó
  bool get isPast => endTime.isBefore(DateTime.now());

  /// Verifica si el horario está en curso
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Verifica si el horario es futuro
  bool get isFuture => startTime.isAfter(DateTime.now());

  /// Días personalizados si aplica el tipo de recurrencia
  List<int>? get customWeekdayNumbers => _parseCustomWeekdays(customRecurrence);

  /// Nombres de los días personalizados si aplica
  List<String>? get customWeekdayNames {
    final numbers = customWeekdayNumbers;
    if (numbers == null || numbers.isEmpty) return null;
    return numbers.map(_weekdayName).toList();
  }

  /// Etiqueta legible para la recurrencia
  String get recurrenceLabel => _friendlyRecurrenceLabel();

  /// Etiqueta legible para el turno
  String get shiftLabel => _shiftTypeLabel(shiftType);

  // ==================== COPIADO ====================

  ScheduleModel copyWith({
    String? id,
    String? employeeName,
    String? employeeId,
    String? position,
    DateTime? startTime,
    DateTime? endTime,
    String? workplace,
    String? description,
    Color? color,
    String? recurrence,
    String? timezone,
    String? customRecurrence,
    String? shiftType,
    String? department,
    List<String>? tasks,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      position: position ?? this.position,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      workplace: workplace ?? this.workplace,
      description: description ?? this.description,
      color: color ?? this.color,
      recurrence: recurrence ?? this.recurrence,
      timezone: timezone ?? this.timezone,
      customRecurrence: customRecurrence ?? this.customRecurrence,
      shiftType: shiftType ?? this.shiftType,
      department: department ?? this.department,
      tasks: tasks ?? this.tasks,
    );
  }

  // ==================== SERIALIZACIÓN ====================

  /// Convertir a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'position': position,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'workplace': workplace,
      'description': description,
      'color': color.value,
      'recurrence': recurrence,
      'timezone': timezone,
      'customRecurrence': customRecurrence,
      'shiftType': shiftType,
      'department': department,
      'tasks': tasks,
    };
  }

  /// Crear desde Map
  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as String,
      employeeName: map['employeeName'] as String,
      employeeId: map['employeeId'] as String,
      position: map['position'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      workplace: map['workplace'] as String,
      description: map['description'] as String?,
      color: Color(map['color'] as int),
      shiftType: map['shiftType'] as String?,
      department: map['department'] as String?,
      recurrence: map['recurrence'] as String? ?? 'no',
      timezone: map['timezone'] as String? ?? 'UTC',
      customRecurrence: map['customRecurrence'] as String?,
      tasks: (map['tasks'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => toMap();

  /// Crear desde JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      ScheduleModel.fromMap(json);

  /// Crear desde la respuesta de la API de horarios
  factory ScheduleModel.fromApi(Map<String, dynamic> json) {
    final scheduleDate = DateTime.parse(json['scheduleDate'] as String);
    final startTimeStr = json['startTime'] as String;
    final endTimeStr = json['endTime'] as String;

    final startTime = _mergeDateAndTime(scheduleDate, startTimeStr);
    final endTime = _mergeDateAndTime(scheduleDate, endTimeStr);

    final employee = json['employee'] as Map<String, dynamic>?;
    final user = employee != null
        ? employee['user'] as Map<String, dynamic>?
        : null;
    final role = user != null ? (user['role'] as Map<String, dynamic>?) : null;

    final firstName = user?['firstName'] as String? ?? '';
    final middleName = user?['middleName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final secondLastName = user?['secondLastName'] as String? ?? '';
    final fullName = [
      firstName,
      middleName,
      lastName,
      secondLastName,
    ].where((part) => part.trim().isNotEmpty).join(' ');

    final position = role != null ? role['name'] as String? : null;

    return ScheduleModel(
      id: json['id'].toString(),
      employeeName: fullName.isNotEmpty ? fullName : 'Empleado',
      employeeId: json['employeeId']?.toString() ?? '',
      position: position ?? 'Empleado',
      startTime: startTime,
      endTime: endTime,
      workplace: json['description'] as String? ?? 'Turno programado',
      description: json['description'] as String?,
      color: _colorForRole(position),
      recurrence: json['recurrence'] as String? ?? 'no',
      timezone: json['timezone'] as String? ?? 'UTC',
      customRecurrence: json['customRecurrence'] as String?,
      shiftType: _shiftTypeFromHour(startTime.hour),
      department: position,
      tasks: null,
    );
  }

  // ==================== HELPERS ====================

  /// Obtener icono según el tipo de turno
  IconData get shiftIcon {
    switch (shiftType?.toLowerCase()) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_twilight;
      case 'night':
        return Icons.nightlight_round;
      default:
        return Icons.schedule;
    }
  }

  /// Color asociado al cargo (para la UI)
  Color get roleColor {
    switch (position.toLowerCase()) {
      case 'entrenador':
        return const Color(0xFF10B981);
      case 'nutricionista':
        return const Color(0xFF0EA5E9);
      case 'psicóloga':
      case 'psicologa':
        return const Color(0xFFF43F5E);
      case 'fisioterapeuta':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static Color _colorForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'entrenador':
        return const Color(0xFF10B981);
      case 'nutricionista':
        return const Color(0xFF0EA5E9);
      case 'psicóloga':
      case 'psicologa':
        return const Color(0xFFF43F5E);
      case 'fisioterapeuta':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  static String _shiftTypeFromHour(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'night';
  }

  static String _shiftTypeLabel(String? shiftType) {
    switch (shiftType?.toLowerCase()) {
      case 'morning':
        return 'Turno Mañana';
      case 'afternoon':
        return 'Turno Tarde';
      case 'night':
        return 'Turno Noche';
      default:
        return 'Programado';
    }
  }

  String _friendlyRecurrenceLabel() {
    switch (recurrence.toLowerCase()) {
      case 'no':
        return 'No se repite';
      case 'personalizado':
        final names = customWeekdayNames;
        if (names != null && names.isNotEmpty) {
          return 'Personalizado (${names.join(', ')})';
        }
        return 'Personalizado';
      default:
        return 'No se repite';
    }
  }

  static List<int>? _parseCustomWeekdays(String? custom) {
    if (custom == null || custom.isEmpty) return null;
    try {
      final decoded = jsonDecode(custom);
      if (decoded is Map && decoded['daysOfWeek'] != null) {
        return _normalizeWeekdays(decoded['daysOfWeek']);
      }
      if (decoded is Iterable) {
        return _normalizeWeekdays(decoded);
      }
    } catch (_) {}
    return null;
  }

  static List<int>? _normalizeWeekdays(dynamic raw) {
    if (raw is! Iterable) return null;
    final normalized = <int>{};
    for (final entry in raw) {
      if (entry is int && entry >= 1 && entry <= 7) {
        normalized.add(entry);
      } else if (entry is String) {
        final weekday = _weekdayFromName(entry);
        if (weekday != null) normalized.add(weekday);
      }
    }
    if (normalized.isEmpty) return null;
    final sorted = normalized.toList()..sort();
    return sorted;
  }

  static int? _weekdayFromName(String name) {
    switch (name.toLowerCase()) {
      case 'monday':
      case 'lunes':
        return DateTime.monday;
      case 'tuesday':
      case 'martes':
        return DateTime.tuesday;
      case 'wednesday':
      case 'miércoles':
      case 'miercoles':
        return DateTime.wednesday;
      case 'thursday':
      case 'jueves':
        return DateTime.thursday;
      case 'friday':
      case 'viernes':
        return DateTime.friday;
      case 'saturday':
      case 'sábado':
      case 'sabado':
        return DateTime.saturday;
      case 'sunday':
      case 'domingo':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  static String _weekdayName(int day) {
    const names = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    if (day < 1 || day > 7) return '';
    return names[day - 1];
  }

  static DateTime _mergeDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  String toString() {
    return 'ScheduleModel(id: $id, employeeName: $employeeName, position: $position, time: $scheduleRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
