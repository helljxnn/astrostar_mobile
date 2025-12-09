import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';

class EventDetailModal extends StatelessWidget {
  final EventApiModel event;

  const EventDetailModal({super.key, required this.event});

  static void show(BuildContext context, EventApiModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => EventDetailModal(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header con botón de cerrar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalles del Evento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del evento
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        event.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Nombre del evento
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Estado del evento
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            event.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(event.status),
                              size: 16,
                              color: _getStatusColor(event.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.status,
                              style: TextStyle(
                                color: _getStatusColor(event.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    _buildSectionTitle('Descripción'),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Información del evento
                  _buildSectionTitle('Información del Evento'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha de inicio',
                      dateFormat.format(event.startDate),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.event,
                      'Fecha de fin',
                      dateFormat.format(event.endDate),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.access_time,
                      'Horario',
                      '${event.startTime} - ${event.endTime}',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.location_on,
                      'Ubicación',
                      event.location,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.phone, 'Teléfono', event.phone),
                  ]),
                  const SizedBox(height: 20),

                  // Categoría y Tipo
                  if (event.category != null || event.type != null) ...[
                    _buildSectionTitle('Clasificación'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      if (event.category != null) ...[
                        _buildInfoRow(
                          Icons.category,
                          'Categoría',
                          event.category!.name,
                        ),
                        if (event.category!.description != null &&
                            event.category!.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              event.category!.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                      if (event.category != null && event.type != null)
                        const Divider(height: 24),
                      if (event.type != null) ...[
                        _buildInfoRow(Icons.label, 'Tipo', event.type!.name),
                        if (event.type!.description != null &&
                            event.type!.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              event.type!.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // Archivo de horario
                  if (event.scheduleFile != null &&
                      event.scheduleFile!.isNotEmpty) ...[
                    _buildSectionTitle('Documentos'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de descarga próximamente'),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: Colors.deepPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Archivo de Horario',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Toca para ver',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // Patrocinadores
                  if (event.sponsors.isNotEmpty) ...[
                    _buildSectionTitle('Patrocinadores'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      event.sponsors.map((sponsor) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child:
                                    sponsor.sponsor.logoUrl != null &&
                                        sponsor.sponsor.logoUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          sponsor.sponsor.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.business,
                                                  color: Colors.grey,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.business,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sponsor.sponsor.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Espacio adicional al final
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Programado':
        return Colors.blue;
      case 'Finalizado':
        return Colors.grey;
      case 'Cancelado':
        return Colors.red;
      case 'Pausado':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Programado':
        return Icons.schedule;
      case 'Finalizado':
        return Icons.check_circle;
      case 'Cancelado':
        return Icons.cancel;
      case 'Pausado':
        return Icons.pause_circle;
      default:
        return Icons.event;
    }
  }
}
