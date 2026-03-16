import 'package:flutter/material.dart';
import 'models/deportista_model.dart';
import 'widgets/date_selector.dart';
import 'widgets/counter_box.dart';
import 'widgets/action_button.dart';
import 'widgets/deportista_tile.dart';
import 'history_page.dart';
import 'package:astrostar_mobile/core/alerts.dart';
import 'package:astrostar_mobile/core/app_colors.dart';
import 'package:astrostar_mobile/data/services/attendance_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime fecha = DateTime.now();

  final AttendanceService _attendanceService = AttendanceService();
  List<Deportista> deportistas = [];
  List<Deportista> deportistasFiltrados = [];
  List<String> _categorias = [];
  bool _isLoading = false;
  String? _error;
  String _categoriaSeleccionada = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _loadAttendance();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategorias() async {
    final cats = await _attendanceService.fetchCategorias();
    if (mounted) setState(() => _categorias = cats);
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _attendanceService.fetchAttendance(
        fecha,
        categoria: _categoriaSeleccionada,
      );
      if (mounted) {
        setState(() {
          deportistas = data;
          deportistasFiltrados = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          deportistas = [];
          deportistasFiltrados = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
    _loadAttendance();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => fecha = picked);
      await _loadAttendance();
    }
  }

  Future<void> _guardarAsistencia() async {
    setState(() => _isLoading = true);
    try {
      await _attendanceService.saveAttendance(fecha, deportistas);
      if (mounted) {
        AppAlerts.showSuccess(
          context,
          "Asistencias actualizadas y guardadas correctamente",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentes = deportistasFiltrados.where((d) => d.presente).length;
    final ausentes = deportistasFiltrados.length - presentes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Fondo gris claro
      appBar: AppBar(
        title: const Text("Asistencia Deportiva"),
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
            if (_isLoading) const LinearProgressIndicator(minHeight: 3),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // Selector de fecha
            DateSelector(date: fecha, onTap: _selectDate),
            const SizedBox(height: 20),

            // Selector de categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFF6C47FF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada.isEmpty ? null : _categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por categoría',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Todas las categorías'),
                        ),
                        ..._categorias.map((categoria) => DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        )),
                      ],
                      onChanged: (value) => _filtrarPorCategoria(value ?? ''),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contadores de asistencia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CounterBox(
                  label: "Presentes",
                  value: presentes,
                  color: AppColors.authPrimaryColor,
                ),
                CounterBox(
                  label: "Ausentes",
                  value: ausentes,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Botones de acción
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C47FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                    onPressed: _isLoading ? null : _guardarAsistencia,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text("Actualizar y Guardar"),
                  ),

                  ActionButton(
                    icon: Icons.history,
                    text: "Historial",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "Deportistas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Buscador
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar deportista...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryPurple),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading && deportistasFiltrados.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (deportistasFiltrados.isEmpty)
              Text(
                _categoriaSeleccionada.isEmpty
                    ? 'No hay registros para la fecha seleccionada.'
                    : 'No hay deportistas en la categoría "$_categoriaSeleccionada".',
                style: const TextStyle(color: Colors.grey),
              )
            else ...[
              Builder(builder: (context) {
                final visibles = deportistasFiltrados.where((d) =>
                  _searchQuery.isEmpty ||
                  d.nombre.toLowerCase().contains(_searchQuery)
                ).toList();
                if (visibles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No se encontró "$_searchQuery"',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                return Column(
                  children: visibles.map((d) => DeportistaTile(
                    deportista: d,
                    onChanged: (val) => setState(() => d.presente = val),
                  )).toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
