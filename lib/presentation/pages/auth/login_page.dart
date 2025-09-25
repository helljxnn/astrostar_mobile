import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8EAF6), Color(0xFFFFFFFF)],
          ),
        ),
        child: Stack(
          children: [
            // Fondo con curva morada
            _buildBackgroundCurve(),
            
            // Contenido
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 40),
                    
                    // Título
                    _buildTitle(),
                    const SizedBox(height: 50),
                    
                    // Campos de texto
                    _buildEmailField(),
                    const SizedBox(height: 25),
                    
                    _buildPasswordField(),
                    const SizedBox(height: 15),
                    
                    // Olvidé contraseña
                    _buildForgotPassword(),
                    const SizedBox(height: 40),
                    
                    // Botón entrar
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCurve() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CurvePainter(),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          "assets/images/logo.png",
          height: 50,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        "INICIAR SESION",
        style: GoogleFonts.montserrat(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: Color(0xFF7E57C2)),
        hintText: "Email",
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFF7E57C2).withOpacity(0.7),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1C4E9)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1C4E9)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7E57C2), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF7E57C2)),
        hintText: "Contraseña",
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFF7E57C2).withOpacity(0.7),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1C4E9)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1C4E9)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7E57C2), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF7E57C2),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Olvidaste tu contraseña ? ",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
            );
          },
          child: Text(
            "Restablecer contraseña !",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7E57C2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7E57C2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF7E57C2).withOpacity(0.3),
        ),
        onPressed: () {},
        child: Text(
          "Entrar",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1C4E9).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, 
                          size.width * 0.15, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.7, 
                          0, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}