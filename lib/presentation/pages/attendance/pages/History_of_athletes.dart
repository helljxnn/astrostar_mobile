import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:astrostar_mobile/core/alerts.dart';

/// =============================================================
/// PANTALLA: HISTORIAL DE ASISTENCIA DEPORTIVA
/// =============================================================
class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  // --------------------------------------------------------------
  // CONTROLADORES DE FECHA
  // --------------------------------------------------------------
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  // --------------------------------------------------------------
  // DATOS DE EJEMPLO (puedes reemplazarlos por tus datos reales)
  // --------------------------------------------------------------
  final List<Map<String, dynamic>> _asistencias = [
    {
      "doc": "12345678",
      "nombre": "Juan Pérez",
      "categoria": "Sub-18",
      "porcentaje": 0.95,
    },
    {
      "doc": "87654321",
      "nombre": "Ana Gómez",
      "categoria": "Sub-16",
      "porcentaje": 0.65,
    },
    {
      "doc": "11223344",
      "nombre": "Luis García",
      "categoria": "Sub-18",
      "porcentaje": 0.35,
    },
  ];

  // =============================================================
  // CONSTRUCCIÓN DE INTERFAZ
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: Text(
          "Historial Asistencia Deportiva",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rango de Fechas",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Campos de fechas
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    "Fecha Inicio",
                    _fechaInicioController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    "Fecha Fin",
                    _fechaFinController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _consultarAsistencia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Consultar",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.download),
                    onSelected: (value) => _exportarArchivo(value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'PDF',
                        child: Text('Exportar a PDF'),
                      ),
                      PopupMenuItem(
                        value: 'Excel',
                        child: Text('Exportar a Excel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Lista de asistencias
            ..._asistencias.map(_buildCard),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // MÉTODOS DE LÓGICA
  // =============================================================

  void _consultarAsistencia() {
    if (_fechaInicioController.text.isEmpty ||
        _fechaFinController.text.isEmpty) {
      AppAlerts.showWarning(context, 'Debe seleccionar ambas fechas');
    } else {
      AppAlerts.showSuccess(context, 'Consulta realizada correctamente ✅');
    }
  }

  Future<void> _exportarArchivo(String tipo) async {
    if (tipo == 'PDF') {
      await _generarPDF();
    } else {
      await _generarExcel();
    }
  }

  // --------------------------------------------------------------
  // GENERAR PDF
  // --------------------------------------------------------------
  Future<void> _generarPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Historial de Asistencia Deportiva",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ["Documento", "Nombre", "Categoría", "Asistencia"],
                data: _asistencias.map((a) {
                  return [
                    a["doc"],
                    a["nombre"],
                    a["categoria"],
                    "${(a["porcentaje"] * 100).toStringAsFixed(0)}%",
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/historial_asistencia.pdf");
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        AppAlerts.showSuccess(context, 'Archivo PDF generado correctamente ✅');
      }

      // ✅ Compartir PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'historial_asistencia.pdf',
      );
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Error al generar PDF: $e');
      }
    }
  }

  // --------------------------------------------------------------
  // GENERAR EXCEL
  // --------------------------------------------------------------
  Future<void> _generarExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Asistencias'];

      sheet.appendRow([
        TextCellValue("Documento"),
        TextCellValue("Nombre"),
        TextCellValue("Categoría"),
        TextCellValue("Asistencia"),
      ]);

      // ✅ Filas de datos
      for (var a in _asistencias) {
        sheet.appendRow([
          TextCellValue(a["doc"].toString()),
          TextCellValue(a["nombre"].toString()),
          TextCellValue(a["categoria"].toString()),
          TextCellValue("${(a["porcentaje"] * 100).toStringAsFixed(0)}%"),
        ]);
      }

      // ✅ Guardar archivo Excel
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/historial_asistencia.xlsx";
      final fileBytes = excel.encode();

      if (fileBytes == null) throw Exception("Error al generar archivo Excel");

      final file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      if (mounted) {
        AppAlerts.showSuccess(
          context,
          'Archivo Excel generado correctamente ✅',
        );
      }

      // ✅ Compartir Excel
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Historial de asistencia');
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Error al generar Excel: $e');
      }
    }
  }

  // =============================================================
  // WIDGETS
  // =============================================================
  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          locale: const Locale('es', 'ES'),
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: "DD/MM/AAAA",
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a) {
    Color color;
    if (a["porcentaje"] > 0.8) {
      color = Colors.green;
    } else if (a["porcentaje"] > 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 32,
            lineWidth: 6,
            percent: a["porcentaje"],
            center: Text(
              "${(a["porcentaje"] * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            progressColor: color,
            backgroundColor: Colors.grey.shade200,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DOCUMENTO ${a["doc"]}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                Text(
                  "NOMBRE ${a["nombre"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "CATEGORÍA ${a["categoria"]}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
