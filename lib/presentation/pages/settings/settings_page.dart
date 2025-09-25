import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF9370DB),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Editar perfil"),
            subtitle: Text("Cambia tu información personal"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text("Cambiar contraseña"),
            subtitle: Text("Actualiza tu clave de acceso"),
          ),
          const Divider(),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // Aquí puedes manejar activación de notificaciones, modo oscuro, etc.
            },
            secondary: const Icon(Icons.notifications),
            title: const Text("Notificaciones"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Cerrar sesión"),
            onTap: () {
              // 👉 Cuando cierres sesión, te envía al LoginPage
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
