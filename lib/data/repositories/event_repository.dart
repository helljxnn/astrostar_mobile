import 'dart:convert';
import 'dart:developer' as developer;
import '../../core/api_service.dart';
import '../models/event_model.dart';

class EventRepository {
  final ApiService _apiService;

  EventRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<EventApiModel>> getEvents() async {
    try {
      developer.log('Fetching events from API...');
      final response = await _apiService.get('/events?limit=100');

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // La respuesta del backend tiene estructura: { success: true, data: [...] }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          developer.log('Events loaded: ${data.length}');
          return data.map((json) => EventApiModel.fromJson(json)).toList();
        } else {
          throw Exception('Respuesta inválida del servidor');
        }
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching events: $e');
      throw Exception('Error al obtener eventos: $e');
    }
  }

  Future<EventApiModel> getEventById(int id) async {
    try {
      final response = await _apiService.get('/events/$id');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // La respuesta del backend tiene estructura: { success: true, data: {...} }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return EventApiModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Respuesta inválida del servidor');
        }
      } else {
        throw Exception('Error al cargar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener evento: $e');
    }
  }
}
