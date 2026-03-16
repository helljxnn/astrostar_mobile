import 'package:flutter/material.dart';
import '../models/deportista_model.dart';
import '../../../../core/app_colors.dart';

class DeportistaTile extends StatelessWidget {
  final Deportista deportista;
  final ValueChanged<bool> onChanged;

  const DeportistaTile({
    super.key,
    required this.deportista,
    required this.onChanged,
  });

  void _showDetalleDeportista(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetalleDeportistaSheet(deportista: deportista),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = deportista.nombre
        .split(" ")
        .map((e) => e[0])
        .take(2)
        .join();
    final statusColor = deportista.presente
        ? AppColors
              .authPrimaryColor // morado #8B5CF6
        : const Color(0xFF64748B); // gris azulado oscuro
    final statusBg = statusColor.withValues(alpha: 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetalleDeportista(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar con iniciales
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deportista.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deportista.categoria,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                          if (deportista.edad != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.cake_outlined,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${deportista.edad} años',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Switch de asistencia + botón info
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: deportista.presente,
                        onChanged: onChanged,
                        activeColor: AppColors.authPrimaryColor,
                        inactiveThumbColor: const Color(0xFF64748B),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      deportista.presente ? 'Presente' : 'Ausente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showDetalleDeportista(context),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sheet de detalle de deportista
class _DetalleDeportistaSheet extends StatelessWidget {
  final Deportista deportista;

  const _DetalleDeportistaSheet({required this.deportista});

  @override
  Widget build(BuildContext context) {
    final initials = deportista.nombre
        .split(" ")
        .map((e) => e[0])
        .take(2)
        .join();
    final statusColor = deportista.presente
        ? AppColors.authPrimaryColor
        : const Color(0xFF64748B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuint,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF9FAFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Indicador de arrastre
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          /// Avatar y nombre
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  deportista.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          /// Estado de asistencia
          _SectionCard(
            title: 'Estado de Asistencia',
            children: [
              _DetailRow(
                icon: deportista.presente ? Icons.check_circle : Icons.cancel,
                text: deportista.presente ? 'Presente' : 'Ausente',
                color: statusColor,
              ),
            ],
          ),

          /// Información personal
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Información Personal',
            children: [
              if (deportista.edad != null) ...[
                _DetailRow(
                  icon: Icons.cake_outlined,
                  text: '${deportista.edad} años',
                ),
                const SizedBox(height: 14),
              ],
              _DetailRow(
                icon: Icons.category_outlined,
                text: 'Categoría: ${deportista.categoria}',
              ),
              if (deportista.documento.isNotEmpty) ...[
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.badge_outlined,
                  text: 'Documento: ${deportista.documento}',
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),

          /// Botón cerrar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18, color: Colors.black87),
              label: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reutilizable: Card de sección
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// Reutilizable: fila detalle
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _DetailRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.grey[700]!;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
