import 'dart:convert';

import 'package:intl/intl.dart';

import '../../core/api_service.dart';
import 'package:astrostar_mobile/presentation/pages/attendance/models/deportista_model.dart';

class AttendanceService {
  final ApiService _api = ApiService();
  final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  String _format(DateTime date) =>
      _fmt.format(DateTime(date.year, date.month, date.day));

  Future<List<Deportista>> fetchAttendance(
    DateTime date, {
    int page = 1,
    int limit = 100,
    String search = '',
    String categoria = '',
  }) async {
    // El backend valida máximo 100
    final safeLimit = limit.clamp(1, 100);
    final dateStr = _format(date);
    final endpoint =
        '/assistance-athletes?date=$dateStr&page=$page&limit=$safeLimit&search=$search&categoria=$categoria';
    final response = await _api.get(endpoint);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      final msg = data['message'] ?? 'No se pudo cargar la asistencia';
      throw Exception(msg);
    }

    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => Deportista.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchHistorySummary({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 20,
    String search = '',
    String categoria = '',
  }) async {
    final start = _format(startDate);
    final end = _format(endDate);
    final endpoint =
        '/assistance-athletes/history/summary?startDate=$start&endDate=$end&page=$page&limit=$limit&search=$search&categoria=$categoria';
    final response = await _api.get(endpoint);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      final msg = data['message'] ?? 'No se pudo cargar el historial';
      throw Exception(msg);
    }

    return data;
  }

  Future<List<String>> fetchCategorias() async {
    final response = await _api.get('/sports-categories?estado=Activo&limit=100');
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) return [];
    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => (e['name'] ?? e['nombre'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  Future<void> saveAttendance(DateTime date, List<Deportista> items) async {
    final endpoint = '/assistance-athletes/bulk';
    final body = {
      'date': _format(date),
      'items': items.map((d) => d.toApi()).toList(),
    };

    final response = await _api.put(endpoint, body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      final msg = data['message'] ?? 'No se pudo guardar la asistencia';
      throw Exception(msg);
    }
  }
}
