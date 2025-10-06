import 'package:flutter/material.dart';
import 'models/deportista_model.dart';
import 'widgets/date_selector.dart';
import 'widgets/counter_box.dart';
import 'widgets/action_button.dart';
import 'widgets/deportista_tile.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime fecha = DateTime.now();

  final List<Deportista> deportistas = [
    Deportista(nombre: "Mateo Ramirez", edad: 18, categoria: "Juvenil"),
    Deportista(
        nombre: "Sofia Rodriguez",
        edad: 22,
        categoria: "Adulto",
        presente: true),
    Deportista(
        nombre: "Lucas Fernandez",
        edad: 20,
        categoria: "Juvenil",
        presente: true),
    Deportista(nombre: "Isabella Torres", edad: 19, categoria: "Juvenil"),
    Deportista(
        nombre: "Diego Vargas", edad: 21, categoria: "Adulto", presente: true),
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => fecha = picked);
  }

  @override
  Widget build(BuildContext context) {
    final presentes = deportistas.where((d) => d.presente).length;
    final ausentes = deportistas.length - presentes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // fondo gris claro
      appBar: AppBar(
        title: const Text("Asistencia Deportiva"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateSelector(date: fecha, onTap: _selectDate),
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),

            // Botones de acción (igual que en tu segunda imagen)
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                // Botón violeta principal
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C47FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text("Actualizar"),
                ),

                // Resto de botones personalizados
                const ActionButton(icon: Icons.history, text: "Historial"),
                const ActionButton(icon: Icons.download, text: "Exportar"),
                const ActionButton(icon: Icons.send, text: "Enviar"),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "Deportistas",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...deportistas.map(
              (d) => DeportistaTile(
                deportista: d,
                onChanged: (val) => setState(() => d.presente = val),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
