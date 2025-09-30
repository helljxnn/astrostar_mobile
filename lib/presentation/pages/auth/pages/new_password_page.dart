import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

// Paleta de colores (misma que las otras páginas)
const Color _primaryColor = Color(0xFF8B5CF6);
const Color _primaryLight = Color(0xFFA78BFA);
const Color _accentColor = Color(0xFFF3F4F6);
const Color _backgroundColor = Color(0xFFFCFCFD);
const Color _textColor = Color(0xFF1F2937);
const Color _textLight = Color(0xFF9CA3AF);
const Color _surfaceColor = Color(0xFFFFFFFF);
const Color _successColor = Color(0xFF10B981);
const Color _errorColor = Color(0xFFEF4444);

class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Estados de validación simplificados
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _mainController.forward();
    _floatingController.repeat();
    _glowController.repeat(reverse: true);

    // Listeners para validaciones en tiempo real
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordMatch);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    String password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });

    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      _passwordsMatch =
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  bool get _isFormValid {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _passwordsMatch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.5),
                radius: 1.5,
                colors: [
                  _primaryColor.withOpacity(0.08),
                  _primaryLight.withOpacity(0.04),
                  _backgroundColor,
                ],
              ),
            ),
          ),

          // Elementos flotantes
          _buildFloatingElements(),

          // Contenido principal
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Botón volver
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildBackButton(),
                          ),

                          const SizedBox(height: 40),

                          // Logo
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildCustomLogo(),
                          ),

                          const SizedBox(height: 60),

                          // Título
                          Text(
                            "Nueva contraseña",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: _textColor,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Subtítulo
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Crea una nueva contraseña segura para\n",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: _textLight,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.email,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Formulario
                          _buildForm(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Elementos flotantes decorativos (igual que otras páginas)
  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingController, _glowController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Orbe principal
            Positioned(
              top: 80 + math.sin(_floatingController.value * 2 * math.pi) * 30,
              right:
                  -20 + math.cos(_floatingController.value * 2 * math.pi) * 40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(
                        0.15 + _glowAnimation.value * 0.1,
                      ),
                      _primaryLight.withOpacity(
                        0.08 + _glowAnimation.value * 0.05,
                      ),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(
                        0.3 + _glowAnimation.value * 0.2,
                      ),
                      blurRadius: 40 + _glowAnimation.value * 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

            // Orbe secundario
            Positioned(
              bottom:
                  150 +
                  math.cos(_floatingController.value * 2 * math.pi + 2) * 25,
              left:
                  -30 +
                  math.sin(_floatingController.value * 2 * math.pi + 2) * 35,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryLight.withOpacity(0.12),
                      _primaryColor.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryLight.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Partículas pequeñas
            ...List.generate(5, (index) {
              double angle =
                  (_floatingController.value * 2 * math.pi) + (index * 1.2);
              return Positioned(
                top: 200 + math.sin(angle) * (50 + index * 20),
                left: 100 + math.cos(angle) * (80 + index * 15),
                child: Container(
                  width: 8 + index * 3,
                  height: 8 + index * 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index.isEven
                        ? _primaryColor.withOpacity(0.3)
                        : _primaryLight.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: (index.isEven ? _primaryColor : _primaryLight)
                            .withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Botón volver
  Widget _buildBackButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Logo
  Widget _buildCustomLogo() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Image.asset(
        'lib/assets/astrostar.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  // Formulario simplificado
  Widget _buildForm() {
    return Column(
      children: [
        // Campo nueva contraseña
        _buildGlowTextField(
          controller: _newPasswordController,
          hint: "Nueva contraseña",
          icon: Icons.lock_rounded,
          isPassword: true,
          isNewPassword: true,
          delay: 400,
        ),

        const SizedBox(height: 22),

        // Campo confirmar contraseña
        _buildGlowTextField(
          controller: _confirmPasswordController,
          hint: "Confirmar contraseña",
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          isConfirmPassword: true,
          delay: 600,
        ),

        const SizedBox(height: 24),

        // Requisitos compactos (solo si está escribiendo)
        if (_newPasswordController.text.isNotEmpty) _buildCompactRequirements(),

        const SizedBox(height: 36),

        // Botón guardar
        _buildGlowButton(),

        const SizedBox(height: 24),
      ],
    );
  }

  // Campo de texto con glow (mismo estilo que LoginPage)
  Widget _buildGlowTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool isNewPassword = false,
    bool isConfirmPassword = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getFieldBorderColor(
                      isConfirmPassword,
                    ).withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: _getFieldBorderColor(isConfirmPassword),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                obscureText: isPassword
                    ? (isNewPassword
                          ? _obscureNewPassword
                          : _obscureConfirmPassword)
                    : false,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    child: Icon(
                      icon,
                      color: _primaryColor.withOpacity(
                        0.8,
                      ), // Color consistente
                      size: 22,
                    ),
                  ),
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(
                    color: _textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  suffixIcon: isPassword
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Indicador de coincidencia para confirmar contraseña
                            if (isConfirmPassword && controller.text.isNotEmpty)
                              Icon(
                                _passwordsMatch
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: _passwordsMatch
                                    ? _successColor
                                    : _errorColor,
                                size: 20,
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                isNewPassword
                                    ? (_obscureNewPassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded)
                                    : (_obscureConfirmPassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded),
                                color: _textLight,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isNewPassword) {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  } else {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFieldBorderColor(bool isConfirmPassword) {
    if (isConfirmPassword && _confirmPasswordController.text.isNotEmpty) {
      return _passwordsMatch
          ? _successColor.withOpacity(0.6)
          : _errorColor.withOpacity(0.6);
    }
    return _accentColor.withOpacity(0.8);
  }

  // Requisitos compactos (estilo minimalista)
  Widget _buildCompactRequirements() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accentColor.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: _primaryColor.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildRequirementChip("8+ chars", _hasMinLength),
                      _buildRequirementChip("A-Z", _hasUppercase),
                      _buildRequirementChip("a-z", _hasLowercase),
                      _buildRequirementChip("0-9", _hasNumber),
                      if (_confirmPasswordController.text.isNotEmpty)
                        _buildRequirementChip("Match", _passwordsMatch),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementChip(String label, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isValid
            ? _successColor.withOpacity(0.1)
            : _textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? _successColor.withOpacity(0.3)
              : _textLight.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isValid ? _successColor : _textLight,
        ),
      ),
    );
  }

  // Botón guardar con glow (mismo estilo que LoginPage)
  Widget _buildGlowButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _isFormValid ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isFormValid
                    ? [_primaryColor, _primaryLight]
                    : [_textLight, _textLight.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isFormValid
                  ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(
                          0.5 + _glowAnimation.value * 0.3,
                        ),
                        blurRadius: 30 + _glowAnimation.value * 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: _primaryLight.withOpacity(0.4),
                        blurRadius: 50,
                        offset: const Offset(0, 15),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _isFormValid
                    ? () {
                        // Mostrar confirmación de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Contraseña actualizada exitosamente',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: _successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        );

                        // Navegar de vuelta al login
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        });
                      }
                    : null,
                child: Center(
                  child: Text(
                    "Guardar contraseña",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
