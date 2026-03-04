import 'package:flutter/material.dart';
import 'models/deportista_model.dart';
import 'widgets/date_selector.dart';
import 'widgets/counter_box.dart';
import 'widgets/action_button.dart';
import 'widgets/deportista_tile.dart';
// import 'pages/History_of_athletes.dart'; // Temporalmente deshabilitado
import 'package:astrostar_mobile/core/alerts.dart'; // Para las alertas

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime fecha = DateTime.now();

  final List<Deportista> deportistas = [
    Deportista(nombre: "Mateo Ramirez", edad: 18, categoria: "Juvenil"),
    Deportista(nombre: "Sofia Rodriguez", edad: 17, categoria: "Juvenil"),
    Deportista(nombre: "Lucas Fernandez", edad: 20, categoria: "Senior"),
    Deportista(nombre: "Isabella Torres", edad: 19, categoria: "Senior"),
    Deportista(nombre: "Daniel Vargas", edad: 16, categoria: "Cadete"),
    Deportista(nombre: "Camila Herrera", edad: 15, categoria: "Cadete"),
  ];

  // Función para seleccionar fecha
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => fecha = picked);
  }

  // -----------------------------------------------------------
  // MÉTODO PARA GUARDAR Y MOSTRAR ALERTA
  // -----------------------------------------------------------
  void _guardarAsistencia() {
    // Simulamos guardar los datos localmente (o podría ser en BD)
    setState(() {
      // Aquí podrías hacer lógica de guardado real
    });

    // Mostrar alerta de confirmación
    AppAlerts.showSuccess(context, "✅ Asistencias actualizadas y guardadas correctamente");
  }

  @override
  Widget build(BuildContext context) {
    final presentes = deportistas.where((d) => d.presente).length;
    final ausentes = deportistas.length - presentes;

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
            // Selector de fecha
            DateSelector(date: fecha, onTap: _selectDate),
            const SizedBox(height: 20),

            // Contadores de asistencia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CounterBox(
                  label: "Presentes",
                  value: presentes,
                  color: Colors.deepPurple,
                ),
                CounterBox(
                  label: "Ausentes",
                  value: ausentes,
                  color: Colors.grey,
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
                  // 🔄 Botón Actualizar (ahora guarda y muestra alerta)
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
                    onPressed: _guardarAsistencia,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text("Actualizar y Guardar"),
                  ),

                  // 📜 Botón Historial
                  ActionButton(
                    icon: Icons.history,
                    text: "Historial",
                    onPressed: () {
                      // Temporalmente deshabilitado
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en mantenimiento')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Título de sección
            const Text(
              "Deportistas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Lista de deportistas
            ...deportistas.map(
              (d) => DeportistaTile(
                deportista: d,
                onChanged: (val) {
                  setState(() {
                    d.presente = val;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
