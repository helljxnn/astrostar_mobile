import 'dart:convert';

import '../../core/api_service.dart';
import 'package:astrostar_mobile/data/models/schedule_model.dart';

class ScheduleService {
  final ApiService _apiService = ApiService();

  Future<List<ScheduleModel>> fetchSchedules({
    int limit = 100,
    String status = 'Programado',
  }) async {
    final endpoint = '/schedules?limit=$limit&status=$status';
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
}
