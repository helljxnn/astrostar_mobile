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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() => _categoriaSeleccionada = categoria);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Deportista> get _visibles => deportistasFiltrados
      .where(
        (d) =>
            _searchQuery.isEmpty ||
            d.nombre.toLowerCase().contains(_searchQuery),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final presentes = deportistasFiltrados.where((d) => d.presente).length;
    final ausentes = deportistasFiltrados.length - presentes;
    final visibles = _visibles;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Asistencia Deportiva"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: CustomScrollView(
        slivers: [
          // Controles superiores
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
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

                  // Selector de fecha
                  DateSelector(date: fecha, onTap: _selectDate),
                  const SizedBox(height: 20),

                  // Filtro categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                            value: _categoriaSeleccionada.isEmpty
                                ? null
                                : _categoriaSeleccionada,
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
                              ..._categorias.map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                _filtrarPorCategoria(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contadores
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
                  const SizedBox(height: 20),

                  // Botones
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Deportistas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Buscador
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar deportista...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryPurple,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey[400],
                                  size: 18,
                                ),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Lista de deportistas
          if (_isLoading && deportistasFiltrados.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (deportistasFiltrados.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _categoriaSeleccionada.isEmpty
                          ? 'No hay registros para la fecha seleccionada.'
                          : 'No hay deportistas en "$_categoriaSeleccionada".',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (visibles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontró "$_searchQuery"',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DeportistaTile(
                    deportista: visibles[index],
                    onChanged: (val) =>
                        setState(() => visibles[index].presente = val),
                  ),
                  childCount: visibles.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
