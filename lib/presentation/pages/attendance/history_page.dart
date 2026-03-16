import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:astrostar_mobile/core/alerts.dart';
import 'package:astrostar_mobile/data/services/attendance_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AttendanceService _attendanceService = AttendanceService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  List<dynamic> _historialData = [];
  Map<String, dynamic>? _pagination;
  bool _isLoading = false;
  bool _hasSearched = false;
  int _currentPage = 1;
  final int _limit = 20;

  Future<void> _selectFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) setState(() => _fechaInicio = picked);
  }

  Future<void> _selectFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) setState(() => _fechaFin = picked);
  }

  Future<void> _consultarHistorial({int page = 1}) async {
    if (_fechaInicio == null || _fechaFin == null) {
      AppAlerts.showError(context, 'Por favor selecciona ambas fechas');
      return;
    }
    if (_fechaFin!.isBefore(_fechaInicio!)) {
      AppAlerts.showError(
        context,
        'La fecha final debe ser posterior a la fecha inicial',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentPage = page;
    });

    try {
      final result = await _attendanceService.fetchHistorySummary(
        startDate: _fechaInicio!,
        endDate: _fechaFin!,
        page: page,
        limit: _limit,
      );

      if (mounted) {
        setState(() {
          _historialData = result['data'] as List<dynamic>? ?? [];
          _pagination = result['pagination'] as Map<String, dynamic>?;
          _isLoading = false;
        });

        if (_historialData.isEmpty) {
          AppAlerts.showWarning(
            context,
            'No se encontraron registros en el rango seleccionado',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppAlerts.showError(
          context,
          'Error al consultar el historial: ${e.toString()}',
        );
      }
    }
  }

  void _limpiar() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _historialData = [];
      _pagination = null;
      _hasSearched = false;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Historial de Asistencias"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(
              label: 'Fecha Inicio',
              date: _fechaInicio,
              onTap: _selectFechaInicio,
            ),
            const SizedBox(height: 16),
            _buildDateSelector(
              label: 'Fecha Fin',
              date: _fechaFin,
              onTap: _selectFechaFin,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C47FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading ? null : () => _consultarHistorial(),
                    icon: const Icon(Icons.search),
                    label: const Text("Consultar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading ? null : _limpiar,
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (!_isLoading && _hasSearched && _historialData.isNotEmpty) ...[
              _buildSummaryHeader(),
              const SizedBox(height: 12),
              _buildHistorialList(),
              const SizedBox(height: 16),
              if (_pagination != null) _buildPagination(),
            ],
            if (!_isLoading && _hasSearched && _historialData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron registros',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final total = _pagination?['total'] ?? _historialData.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Resultados",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "$total deportistas",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHistorialList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ..._historialData.asMap().entries.map((entry) {
            return _buildTableRow(
              entry.value as Map<String, dynamic>,
              entry.key,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6C47FF).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerText('DEPORTISTA')),
          Expanded(child: _headerText('PRES.', center: true)),
          Expanded(child: _headerText('AUS.', center: true)),
          Expanded(child: _headerText('%', center: true)),
        ],
      ),
    );
  }

  Widget _headerText(String text, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> item, int index) {
    final isEven = index % 2 == 0;
    final percent = item['percent'] as int? ?? 0;
    final Color percentColor = percent >= 75
        ? const Color(0xFF8B5CF6)
        : percent >= 50
        ? const Color(0xFF9BE9FF)
        : const Color(0xFFB595FF);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[50] : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if ((item['categoria'] ?? '').toString().isNotEmpty)
                  Text(
                    item['categoria'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item['present'] ?? 0}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${item['absent'] ?? 0}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9BE9FF),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$percent%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: percentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = _pagination?['pages'] as int? ?? 1;
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () => _consultarHistorial(page: _currentPage - 1)
              : null,
        ),
        Text(
          '$_currentPage / $totalPages',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => _consultarHistorial(page: _currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF6C47FF),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? _dateFormat.format(date)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: date != null ? Colors.black : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
