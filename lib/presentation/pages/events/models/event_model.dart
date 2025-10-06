import 'package:flutter/material.dart';

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
  });

  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  String get dateRange => _formatDateRange(startDate, endDate);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start == end) {
      return _formatDate(start);
    }
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
