import 'package:flutter/material.dart';
import '../../../../core/alerts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estados de configuración
  bool _emailNotifications = true;

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
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Botón de regreso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Configuración',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Icono de configuración
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Personaliza tu experiencia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Sección de Notificaciones
                  _buildSectionTitle('Notificaciones'),
                  const SizedBox(height: 10),
                  _buildModernCard([
                    _buildSwitchOption(
                      icon: Icons.email_outlined,
                      title: 'Notificaciones por Email',
                      subtitle: 'Recibir actualizaciones por correo',
                      value: _emailNotifications,
                      color: const Color(0xFF74B9FF),
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        AppAlerts.showSuccess(
                          context,
                          value
                              ? 'Emails activados'
                              : 'Emails desactivados',
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Sección de Información
                  _buildSectionTitle('Información'),
                  const SizedBox(height: 10),
                  _buildModernCard([
                    _buildInfoOption(
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      subtitle: 'Versión 1.0.0',
                      color: const Color(0xFF6C5CE7),
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildInfoOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Política de Privacidad',
                      subtitle: 'Términos y condiciones',
                      color: const Color(0xFF74B9FF),
                      onTap: () {
                        AppAlerts.showInfo(
                          context,
                          'Abriendo política de privacidad...',
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildInfoOption(
                      icon: Icons.help_outline,
                      title: 'Ayuda y Soporte',
                      subtitle: 'Obtener asistencia',
                      color: const Color(0xFF00B894),
                      onTap: () {
                        AppAlerts.showInfo(
                          context,
                          'Contactando con soporte...',
                        );
                      },
                    ),
                  ]),

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
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
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

  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
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
      trailing: Transform.scale(
        scale: 0.9,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildInfoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6C5CE7)),
              SizedBox(width: 10),
              Text('Acerca de'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Versión 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Aplicación desarrollada con Flutter',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              Text(
                '© 2025 Todos los derechos reservados',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
