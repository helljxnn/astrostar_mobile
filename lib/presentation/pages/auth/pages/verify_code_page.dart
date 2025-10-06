import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'new_password_page.dart';
import '../validators/auth_validators.dart';
import '../../../../core/alerts.dart';
import '../../../../core/app_colors.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage>
    with TickerProviderStateMixin {
  // Controladores para cada campo de código
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  DateTime? _lastResendAttempt;
  // ignore: unused_field
  DateTime? _lastVerifyAttempt;
  
  int _resendCooldown = 0;

  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shakeAnimation;

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

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _mainController.forward();
    _floatingController.repeat();
    _glowController.repeat(reverse: true);

    // Iniciar cooldown de reenvío
    _startResendCooldown();

    // Auto-focus en el primer campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Iniciar cooldown para reenvío
  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _updateCooldown();
  }

  void _updateCooldown() {
    if (_resendCooldown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _resendCooldown--);
          _updateCooldown();
        }
      });
    }
  }

  // Trigger animación de shake para errores
  void _triggerShakeAnimation() {
    _shakeController.reset();
    _shakeController.forward();
  }

  // FUNCIÓN DE VERIFICACIÓN CON VALIDACIONES COMPLETAS
  Future<void> _performCodeVerification() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Obtener dígitos del código
      List<String> codeDigits = _codeControllers.map((c) => c.text).toList();

      // Usar validador centralizado
      final isValid = AuthFormValidators.validateCodeForm(context, codeDigits);

      if (!isValid) {
        _triggerShakeAnimation();
        setState(() => _isLoading = false);
        return;
      }

      // Actualizar último intento
      _lastVerifyAttempt = DateTime.now();

      // Simular delay de verificación
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Mostrar confirmación y navegar
        AppAlerts.showCodeVerified(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordPage(email: widget.email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(
          context,
          'Error al verificar el código. Intente nuevamente',
        );
        _triggerShakeAnimation();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FUNCIÓN DE REENVÍO CON VALIDACIONES
  Future<void> _performCodeResend() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      // Verificar rate limiting
      if (AuthUtils.isRateLimited(_lastResendAttempt, 1)) {
        AppAlerts.showRateLimit(context, 1);
        setState(() => _isResending = false);
        return;
      }

      // Verificar conexión
      if (!await AuthUtils.hasInternetConnection()) {
        AppAlerts.showNoConnection(context);
        setState(() => _isResending = false);
        return;
      }

      // Actualizar último intento de reenvío
      _lastResendAttempt = DateTime.now();

      // Simular delay de reenvío
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Limpiar campos y reiniciar cooldown
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        _startResendCooldown();

        AppAlerts.showCodeResent(context);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Error al reenviar el código');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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

                          // Logo
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildCustomLogo(),
                          ),

                          const SizedBox(height: 60),

                          // Título
                          Text(
                            "Verificar código",
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
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Hemos enviado un código de verificación a\n",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.authTextLight,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.email,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.authPrimaryColor,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Campos de código CON SHAKE ANIMATION
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  math.sin(
                                        _shakeAnimation.value * math.pi * 8,
                                      ) *
                                      10,
                                  0,
                                ),
                                child: _buildCodeInputs(),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Botón continuar CON VALIDACIONES
                          _buildGlowButton(),

                          const SizedBox(height: 24),

                          // Reenviar código CON COOLDOWN
                          _buildResendButton(),

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

  // Elementos flotantes decorativos
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

  // Campos de código
  Widget _buildCodeInputs() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 40),
          child: Opacity(
            opacity: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return _buildCodeField(index);
              }),
            ),
          ),
        );
      },
    );
  }

  // Campo individual de código CON VALIDACIÓN
  Widget _buildCodeField(int index) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 65,
          height: 75,
          decoration: BoxDecoration(
            color: AppColors.authSurfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? AppColors.authPrimaryColor
                  : AppColors.authAccentColor.withOpacity(0.8),
              width: _focusNodes[index].hasFocus ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _focusNodes[index].hasFocus
                    ? AppColors.authPrimaryColor.withOpacity(
                        0.25 + _glowAnimation.value * 0.15,
                      )
                    : AppColors.authPrimaryColor.withOpacity(0.08),
                blurRadius: _focusNodes[index].hasFocus
                    ? 25 + _glowAnimation.value * 15
                    : 20,
                offset: const Offset(0, 8),
                spreadRadius: _focusNodes[index].hasFocus ? 2 : 1,
              ),
            ],
          ),
          child: TextField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.authTextColor,
            ),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 20),
            ),
            onChanged: (value) {
              // Validar dígito individual
              final digitResult = CodeValidator.validateSingleDigit(value);
              if (!digitResult.isValid && value.isNotEmpty) {
                // Limpiar si es inválido
                _codeControllers[index].clear();
                return;
              }

              if (value.length == 1 && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      },
    );
  }

  // Botón continuar CON VALIDACIONES
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
              onTap: _isLoading ? null : _performCodeVerification,
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
                            "Verificando código...",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "Continuar",
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

  // Botón reenviar código CON COOLDOWN Y VALIDACIONES
  Widget _buildResendButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: (_resendCooldown > 0 || _isResending)
                    ? null
                    : _performCodeResend,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isResending)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.authPrimaryColor,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.refresh_rounded,
                          color: _resendCooldown > 0
                              ? AppColors.authTextLight
                              : AppColors.authPrimaryColor,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _resendCooldown > 0
                            ? "Reenviar en ${_resendCooldown}s"
                            : _isResending
                            ? "Reenviando..."
                            : "Reenviar código",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _resendCooldown > 0
                              ? AppColors.authTextLight
                              : AppColors.authPrimaryColor,
                        ),
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
