import 'package:flutter/material.dart';
import '../../../presentation/pages/auth/validators/auth_validators.dart';
import './validators/edit_profile_validators.dart'; // Importar las validaciones
import '../../../core/alerts.dart';
import './current_user.dart'; // Importar datos de usuario simulado
import '../../../core/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialLastName;
  final int initialColorIndex;
  final Function(String name, String lastName, int colorIndex) onSave;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialLastName,
    required this.initialColorIndex,
    required this.onSave,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para información personal
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;

  // Controladores para los campos de contraseña
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Para mostrar/ocultar contraseñas
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Estado de validación de contraseña en tiempo real
  Map<String, dynamic>? _passwordValidation;
  String? _passwordMatchError;

  // Color del avatar
  final List<Color> _avatarColors = AppColors.avatarColors;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _selectedColorIndex = widget.initialColorIndex;

    // Listener para validación en tiempo real de nueva contraseña
    _newPasswordController.addListener(_validatePasswordRealTime);
    _confirmPasswordController.addListener(_validatePasswordMatchRealTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswordRealTime() {
    if (_newPasswordController.text.isNotEmpty) {
      setState(() {
        _passwordValidation = PasswordValidator.validateRealTime(
          _newPasswordController.text,
        );
      });
    } else {
      setState(() {
        _passwordValidation = null;
      });
    }
  }

  void _validatePasswordMatchRealTime() {
    if (_confirmPasswordController.text.isNotEmpty) {
      setState(() {
        _passwordMatchError = PasswordValidator.validateMatchRealTime(
          _newPasswordController.text,
          _confirmPasswordController.text,
        );
      });
    } else {
      setState(() {
        _passwordMatchError = null;
      });
    }
  }

  String _getInitials() {
    String firstName = _nameController.text.trim();
    String lastName = _lastNameController.text.trim();

    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
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
            // Header con gradiente y avatar
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
                            'Editar Perfil',
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
                    // Avatar con iniciales
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _avatarColors[_selectedColorIndex],
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
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showColorSelector(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.palette,
                                color: _avatarColors[_selectedColorIndex],
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _showColorSelector(),
                      child: const Text(
                        'Cambiar color',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_nameController.text} ${_lastNameController.text}',
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Formulario
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    _buildSectionTitle('Información Personal'),
                    const SizedBox(height: 10),

                    _buildModernCard([
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        onChanged: (value) => setState(() {}),
                        validator: EditProfileValidators
                            .validateName, // Usar validador del EditProfileValidators
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Apellido',
                        icon: Icons.person_outline,
                        onChanged: (value) => setState(() {}),
                        validator: EditProfileValidators
                            .validateLastName, // Usar validador del EditProfileValidators
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Seguridad'),
                    const SizedBox(height: 10),

                    _buildModernCard([
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'Contraseña Actual',
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                        validator: (value) =>
                            EditProfileValidators.validateCurrentPassword(
                              value,
                              isChangingPassword:
                                  _newPasswordController.text.isNotEmpty ||
                                  _confirmPasswordController.text.isNotEmpty,
                            ), // Usar validador del EditProfileValidators
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Nueva Contraseña',
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final result =
                                PasswordValidator.validateNewPassword(value);
                            if (!result.isValid) {
                              return result.errorMessage;
                            }
                          }
                          return null;
                        },
                      ),
                      if (_passwordValidation != null) ...[
                        const SizedBox(height: 12),
                        _buildPasswordStrengthIndicator(),
                      ],
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Nueva Contraseña',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty) {
                            final result =
                                PasswordValidator.validatePasswordMatch(
                                  _newPasswordController.text,
                                  value ?? '',
                                );
                            if (!result.isValid) {
                              return result.errorMessage;
                            }
                          }
                          return null;
                        },
                      ),
                      if (_passwordMatchError != null &&
                          _confirmPasswordController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _passwordMatchError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ]),

                    const SizedBox(height: 16),

                    // Información de seguridad
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C5CE7).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF6C5CE7),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requisitos de contraseña:',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• Mínimo 8 caracteres\n• Al menos una mayúscula\n• Al menos una minúscula\n• Al menos un número\n• Al menos un carácter especial',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C5CE7)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordValidation == null) return const SizedBox.shrink();

    final strength = _passwordValidation!['strength'] as int;
    final strengthText = _passwordValidation!['strengthText'] as String;

    Color strengthColor;
    if (strength <= 2) {
      strengthColor = Colors.red;
    } else if (strength <= 4) {
      strengthColor = Colors.orange;
    } else if (strength == 5) {
      strengthColor = Colors.yellow[700]!;
    } else {
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 7,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showColorSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selecciona un color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(_avatarColors.length, (index) {
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                        Navigator.pop(context);
                        AppAlerts.showSuccess(context, 'Color actualizado');
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _avatarColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _avatarColors[index].withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método principal de guardado usando EditProfileValidators
  Future<void> _saveProfile() async {
    // Usar el validador completo del EditProfileValidators
    final isValid = await EditProfileValidators.validateProfileForm(
      context,
      formKey: _formKey,
      name: _nameController.text,
      lastName: _lastNameController.text,
      initialName: widget.initialName,
      initialLastName: widget.initialLastName,
      colorIndex: _selectedColorIndex,
      initialColorIndex: widget.initialColorIndex,
      currentPassword: _currentPasswordController.text.isNotEmpty
          ? _currentPasswordController.text
          : null,
      newPassword: _newPasswordController.text.isNotEmpty
          ? _newPasswordController.text
          : null,
      confirmPassword: _confirmPasswordController.text.isNotEmpty
          ? _confirmPasswordController.text
          : null,
    );

    if (!isValid) return;

    // Si la validación pasa, proceder con el guardado
    try {
      // Determinar si se está cambiando contraseña
      bool isChangingPassword = _newPasswordController.text.isNotEmpty;

      if (isChangingPassword) {
        // Mostrar mensaje específico para cambio de contraseña
        AppAlerts.showPasswordUpdated(context);
      }

      // Guardar cambios de perfil
      widget.onSave(
        _nameController.text.trim(),
        _lastNameController.text.trim(),
        _selectedColorIndex,
      );

      // Mostrar mensaje de éxito
      AppAlerts.showSuccess(
        context,
        'Perfil actualizado correctamente',
        icon: Icons.check_circle_rounded,
      );

      // Limpiar campos de contraseña
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Limpiar estado de validación
      setState(() {
        _passwordValidation = null;
        _passwordMatchError = null;
      });

      // Volver a la pantalla anterior después de 1 segundo
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      // Manejar errores
      AppAlerts.showError(
        context,
        'Error al actualizar el perfil: $e',
        icon: Icons.error_outline_rounded,
      );
    }
  }
}
