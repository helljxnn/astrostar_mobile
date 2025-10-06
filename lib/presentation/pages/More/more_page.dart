import 'package:flutter/material.dart';
import './edit_profile_page.dart';
import './current_user.dart'; // Importar datos de usuario simulado
import './settings_page.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  // Datos del perfil
  String _userName = 'Juan';
  String _userLastName = 'Pérez';
  int _avatarColorIndex = 0;

  // Colores del avatar (mismos que en EditProfilePage)
  final List<Color> _avatarColors = [
    const Color(0xFF6C5CE7),
    const Color(0xFF74B9FF),
    const Color(0xFFFF6B95),
    const Color(0xFFFD79A8),
    const Color(0xFF00B894),
    const Color(0xFFFDCB6E),
  ];

  String _getInitials() {
    String initials = '';
    if (_userName.isNotEmpty) {
      initials += _userName[0].toUpperCase();
    }
    if (_userLastName.isNotEmpty) {
      initials += _userLastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'U' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFA57FF0), Color(0xFFC8C6DD)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 40),
                  child: Column(
                    children: [
                      // Avatar con iniciales y color
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _avatarColors[_avatarColorIndex],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '$_userName $_userLastName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        CurrentUser.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sección de opciones principales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSectionTitle('Mi Cuenta'),
                  _buildModernCard([
                    _buildMenuOption(
                      icon: Icons.person_outline,
                      title: 'Editar Perfil',
                      subtitle: 'Actualizar información personal',
                      color: const Color(0xFF6C5CE7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              initialName: _userName,
                              initialLastName: _userLastName,
                              initialColorIndex: _avatarColorIndex,
                              onSave: (name, lastName, colorIndex) {
                                setState(() {
                                  _userName = name;
                                  _userLastName = lastName;
                                  _avatarColorIndex = colorIndex;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildSectionTitle('Configuración'),
                  _buildModernCard([
                    _buildMenuOption(
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                      subtitle: 'Preferencias de la aplicación',
                      color: const Color(0xFF74B9FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Botón de cerrar sesión
                  _buildLogoutButton(),

                  const SizedBox(height: 20),

                  // Información de la app
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withOpacity(0.2)),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, "/login");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
