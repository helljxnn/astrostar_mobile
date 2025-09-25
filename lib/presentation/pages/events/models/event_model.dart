import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String timeRange;
  final String place;
  final String status;
  final DateTime date;
  final Color color;

  EventModel({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.place,
    required this.status,
    required this.date,
    required this.color,
  });
}
