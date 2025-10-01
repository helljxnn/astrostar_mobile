import 'package:flutter/material.dart';

// Enum para los tipos de especialidad
enum SpecialtyType { physiotherapy, nutrition, psychology }

extension SpecialtyTypeExtension on SpecialtyType {
  String get name {
    switch (this) {
      case SpecialtyType.physiotherapy:
        return 'Fisioterapia';
      case SpecialtyType.nutrition:
        return 'Nutrición';
      case SpecialtyType.psychology:
        return 'Psicología';
      default:
        return '';
    }
  }
}

// Enum para el estado de la cita
enum AppointmentStatus { scheduled, canceled }

extension AppointmentStatusExtension on AppointmentStatus {
  String get name {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Agendada';
      case AppointmentStatus.canceled:
        return 'Cancelada';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Colors.green;
      case AppointmentStatus.canceled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Icons.check_circle_outline;
      case AppointmentStatus.canceled:
        return Icons.cancel_outlined;
    }
  }
}

// Modelo para el Deportista
class Athlete {
  final String id;
  final String name;

  Athlete({required this.id, required this.name});
}

// Modelo para el Especialista
class Specialist {
  final String id;
  final String name;
  final SpecialtyType specialty;
  final String schedule; // Horario como un simple String para el ejemplo

  Specialist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.schedule,
  });
}

// Modelo para la Cita
class Appointment {
  final String id;
  final Athlete athlete;
  final Specialist specialist;
  final DateTime dateTime;
  final String description;
  AppointmentStatus status;
  String? cancellationReason;

  Appointment({
    required this.id,
    required this.athlete,
    required this.specialist,
    required this.dateTime,
    required this.description,
    this.status = AppointmentStatus.scheduled,
    this.cancellationReason,
  });
}
