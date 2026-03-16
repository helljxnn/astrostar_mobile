import 'package:flutter/material.dart';
import '../../../../data/models/event_model.dart';

class EventModel {
  final String id;
  final String title;
  final String timeRange;
  final String place;
  final String status;
  final DateTime date;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final String? description;
  final String? imageUrl;
  final List<String> sponsors;
  final String? phone;
  final String? type;
  final String? category;
  final List<String> categories;

  EventModel({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.place,
    required this.status,
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.color,
    this.description,
    this.imageUrl,
    this.sponsors = const [],
    this.phone,
    this.type,
    this.category,
    this.categories = const [],
  });

  factory EventModel.fromApiModel(EventApiModel apiModel) {
    // Mapear colores según el tipo de evento
    Color eventColor;
    final typeName = apiModel.type?.name ?? '';

    switch (typeName) {
      case 'Festival':
        eventColor = const Color(0xFF9BFFB6); // Verde
        break;
      case 'Torneo':
        eventColor = const Color(0xFF9BE9FF); // Azul
        break;
      case 'Clausura':
        eventColor = const Color(0xFFB595FF); // Morado
        break;
      case 'Taller':
        eventColor = const Color(0xFFFF95E5); // Rosado
        break;
      default:
        eventColor = const Color(0xFF9BE9FF); // Azul por defecto
    }

    // Extraer categorías si existen
    List<String> categoryList = [];
    if (apiModel.category != null) {
      categoryList.add(apiModel.category!.name);
    }

    return EventModel(
      id: apiModel.id.toString(),
      title: apiModel.name,
      timeRange: '${apiModel.startTime}-${apiModel.endTime}',
      place: apiModel.location,
      status: apiModel.status.replaceAll('_', ' '),
      date: apiModel.startDate,
      startDate: apiModel.startDate,
      endDate: apiModel.endDate,
      color: eventColor,
      description: apiModel.description,
      imageUrl: apiModel.imageUrl,
      sponsors: apiModel.sponsors.map((s) => s.sponsor.name).toList(),
      phone: apiModel.phone,
      type: apiModel.type?.name,
      category: apiModel.category?.name,
      categories: categoryList,
    );
  }
}
