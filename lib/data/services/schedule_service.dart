import 'dart:convert';

import '../../core/api_service.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';

class ScheduleService {
  final ApiService _apiService = ApiService();

  Future<List<ScheduleModel>> fetchSchedules({
    int limit = 100,
    int page = 1,
    int? employeeId,
    String? dayOfWeek,
  }) async {
    final buffer = StringBuffer('/schedules?limit=$limit&page=$page');
    if (employeeId != null) buffer.write('&employeeId=$employeeId');
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      buffer.write('&dayOfWeek=$dayOfWeek');
    }
    final endpoint = buffer.toString();
    final response = await _apiService.get(endpoint);

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200 || responseData['success'] != true) {
      final message = responseData['message'] ?? 'No se pudieron cargar los horarios';
      throw Exception(message);
    }

    final rawSchedules = responseData['data'] as List<dynamic>? ?? [];
    return rawSchedules
        .map((raw) => ScheduleModel.fromApi(raw as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSchedule(Map<String, dynamic> scheduleData) async {
    final response = await _apiService.post('/schedules', scheduleData);
    final responseData = jsonDecode(response.body);

    if (response.statusCode != 201 || responseData['success'] != true) {
      final message = responseData['message'] ?? 'No se pudo crear el horario';
      throw Exception(message);
    }
  }
}
