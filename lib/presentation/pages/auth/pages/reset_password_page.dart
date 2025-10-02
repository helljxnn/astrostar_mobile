import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'verify_code_page.dart';
import '../validators/auth_validators.dart';
import '../../../../core/alerts.dart';
import '../../../../core/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  DateTime? _lastResetAttempt;

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
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // FUNCIÓN DE RESET CON VALIDACIONES COMPLETAS
  Future<void> _performPasswordReset() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Usar validador centralizado
      final isValid = await AuthFormValidators.validateResetForm(
        context,
        _emailController.text,
        lastAttempt: _lastResetAttempt,
      );

      if (!isValid) {
        setState(() => _isLoading = false);
        return;
      }

      // Actualizar último intento
      _lastResetAttempt = DateTime.now();

      // Simular delay de envío
      await Future.delayed(const Duration(seconds: 2));

      // Obtener email sanitizado
      final sanitizedEmail = AuthUtils.sanitizeInput(
        _emailController.text.trim().toLowerCase(),
      );

      if (mounted) {
        // Mostrar confirmación y navegar
        AppAlerts.showCodeSent(context, sanitizedEmail);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodePage(email: sanitizedEmail),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(
          context,
          'Error al enviar el código. Intente nuevamente',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackgroundColor,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.5),
                radius: 1.5,
                colors: [
                  AppColors.authPrimaryColor.withOpacity(0.08),
                  AppColors.authPrimaryLight.withOpacity(0.04),
                  AppColors.authBackgroundColor,
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

                          // Logo - CORREGIDO AL MISMO TAMAÑO
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildCustomLogo(),
                          ),

                          const SizedBox(height: 60),

                          // Título
                          Text(
                            "Restablecer contraseña",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.authTextColor,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Subtítulo
                          Text(
                            "Ingrese el correo electrónico asociado\npara el restablecimiento",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.authTextLight,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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

  // Elementos flotantes decorativos (mismo que LoginPage)
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
                      AppColors.authPrimaryColor.withOpacity(
                        0.15 + _glowAnimation.value * 0.1,
                      ),
                      AppColors.authPrimaryLight.withOpacity(
                        0.08 + _glowAnimation.value * 0.05,
                      ),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.authPrimaryColor.withOpacity(
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
                      AppColors.authPrimaryLight.withOpacity(0.12),
                      AppColors.authPrimaryColor.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.authPrimaryLight.withOpacity(0.2),
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
                        ? AppColors.authPrimaryColor.withOpacity(0.3)
                        : AppColors.authPrimaryLight.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (index.isEven
                                    ? AppColors.authPrimaryColor
                                    : AppColors.authPrimaryLight)
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
                color: AppColors.authSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.authPrimaryColor.withOpacity(0.08),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.authPrimaryColor,
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

  // Logo - CORREGIDO: Mismo tamaño que LoginPage (160x160)
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

  // Formulario
  Widget _buildForm() {
    return Column(
      children: [
        // Campo email
        _buildGlowTextField(
          controller: _emailController,
          hint: "Correo electrónico",
          icon: Icons.email_rounded,
          delay: 400,
        ),

        const SizedBox(height: 36),

        // Botón enviar CON VALIDACIONES
        _buildGlowButton(),

        const SizedBox(height: 24),
      ],
    );
  }

  // Campo de texto con glow
  Widget _buildGlowTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
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
                color: AppColors.authSurfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.authPrimaryColor.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: AppColors.authAccentColor.withOpacity(0.8),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.authTextColor,
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
                      color: AppColors.authPrimaryColor.withOpacity(0.8),
                      size: 22,
                    ),
                  ),
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.authTextLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Botón con glow CON VALIDACIONES
  Widget _buildGlowButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.authPrimaryColor, AppColors.authPrimaryLight],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.authPrimaryColor.withOpacity(
                  0.5 + _glowAnimation.value * 0.3,
                ),
                blurRadius: 30 + _glowAnimation.value * 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.authPrimaryLight.withOpacity(0.4),
                blurRadius: 50,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isLoading ? null : _performPasswordReset,
              child: Center(
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Enviando código...",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "Enviar",
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
        );
      },
    );
  }
}
