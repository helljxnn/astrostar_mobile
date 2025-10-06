import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../../../../core/app_colors.dart';

class EventDetailSheet extends StatelessWidget {
  final EventModel event;

  const EventDetailSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min, // se ajusta al contenido
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Título
          Center(
            child: Text(
              event.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Categoría
          Center(
            child: Chip(
              label: Text(
                event.category,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: event.color.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
            ),
          ),
          const SizedBox(height: 28),

          /// Fecha y hora
          _SectionCard(
            title: 'Fecha y hora',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      text:
                          'Inicio: ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      text:
                          'Fin: ${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.access_time_rounded,
                      text: 'Hora inicio: ${event.startTime.format(context)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.access_time_outlined,
                      text: 'Hora fin: ${event.endTime.format(context)}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// Ubicación
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Ubicación',
            children: [
              _DetailRow(icon: Icons.location_on_rounded, text: event.place),
            ],
          ),

          /// Estado
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Estado',
            children: [
              _DetailRow(
                icon: Icons.info_outline_rounded,
                text: event.status,
              ),
            ],
          ),

          /// Patrocinadores
          if (event.sponsors.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Patrocinadores',
              children: [
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: event.sponsors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return Chip(
                        label: Text(
                          event.sponsors[index],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: AppColors.primaryPurpleLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          /// Botón cerrar minimalista
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

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[100],
          child: Icon(icon, size: 18, color: Colors.grey[700]),
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
