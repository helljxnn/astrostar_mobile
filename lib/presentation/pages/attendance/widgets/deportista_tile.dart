import 'package:flutter/material.dart';
import '../models/deportista_model.dart';

class DeportistaTile extends StatelessWidget {
  final Deportista deportista;
  final ValueChanged<bool> onChanged;

  const DeportistaTile({super.key, required this.deportista, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final initials = deportista.nombre.split(" ").map((e) => e[0]).take(2).join();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade100,
        child: Text(initials, style: const TextStyle(color: Colors.black)),
      ),
      title: Text(deportista.nombre),
      subtitle: Text("${deportista.edad} años, Cat. ${deportista.categoria}"),
      trailing: Switch(
        value: deportista.presente,
        onChanged: onChanged,
        activeThumbColor: Colors.deepPurple,
      ),
    );
  }
}
