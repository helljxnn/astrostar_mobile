import 'package:flutter/material.dart';

/// Modelo para horarios de empleados
class ScheduleModel {
  final String id;
  final String employeeName;
  final String employeeId;
  final String position; // Cargo: "Nutricionista", "Fisioterapeuta", etc.
  final DateTime startTime;
  final DateTime endTime;
  final String workplace; // Lugar de trabajo
  final String? description; // Descripción del turno
  final Color color;
  
  // Campos adicionales opcionales
  final String? shiftType; // "morning", "afternoon", "night"
  final String? status; // "scheduled", "completed", "cancelled"
  final String? department; // Departamento
  final List<String>? tasks; // Tareas asignadas

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
    this.shiftType,
    this.status,
    this.department,
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
  DateTime get scheduleDate => DateTime(startTime.year, startTime.month, startTime.day);

  /// Día de la semana (Lunes, Martes, etc.)
  String get dayOfWeek {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
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

  // ==================== MÉTODOS PRIVADOS ====================
  
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

  // ==================== COPY WITH ====================
  
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
    String? shiftType,
    String? status,
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
      shiftType: shiftType ?? this.shiftType,
      status: status ?? this.status,
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
      'shiftType': shiftType,
      'status': status,
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
      status: map['status'] as String?,
      department: map['department'] as String?,
      tasks: (map['tasks'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => toMap();

  /// Crear desde JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel.fromMap(json);

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

  /// Obtener color según el estado
  Color get statusColor {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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