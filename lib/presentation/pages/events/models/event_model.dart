import 'package:flutter/material.dart';
import '../../../../data/models/event_model.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String place;
  final String status;
  final String category;
  final List<String> sponsors;
  final Color color;
  final String? description;
  final String? imageUrl;
  final List<String> sponsors;

  EventModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.status,
    required this.category,
    required this.sponsors,
    required this.color,
    this.description,
    this.imageUrl,
    this.sponsors = const [],
  });

  factory EventModel.fromApiModel(EventApiModel apiModel) {
    // Mapear colores según el estado
    Color statusColor;
    switch (apiModel.status) {
      case 'Programado':
        statusColor = const Color(0xFF9BE9FF);
        break;
      case 'Finalizado':
        statusColor = const Color(0xFF9BFFB6);
        break;
      case 'Cancelado':
        statusColor = const Color(0xFFFF95E5);
        break;
      case 'En_pausa':
        statusColor = const Color(0xFFB595FF);
        break;
      default:
        statusColor = const Color(0xFF9BE9FF);
    }

    return EventModel(
      id: apiModel.id.toString(),
      title: apiModel.name,
      timeRange: '${apiModel.startTime}-${apiModel.endTime}',
      place: apiModel.location,
      status: apiModel.status.replaceAll('_', ' '),
      date: apiModel.startDate,
      color: statusColor,
      description: apiModel.description,
      imageUrl: apiModel.imageUrl,
      sponsors: apiModel.sponsors.map((s) => s.sponsor.name).toList(),
    );
  }
}
