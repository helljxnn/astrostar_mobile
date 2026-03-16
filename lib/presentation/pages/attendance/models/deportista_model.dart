class Deportista {
  final int athleteId;
  final String nombre;
  final String documento;
  final int? edad;
  final String categoria;
  bool presente;
  String observacion;

  Deportista({
    required this.athleteId,
    required this.nombre,
    required this.documento,
    required this.categoria,
    this.edad,
    this.presente = false,
    this.observacion = '',
  });

  factory Deportista.fromApi(Map<String, dynamic> json) {
    return Deportista(
      athleteId: (json['athleteId'] ?? json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? 'Sin nombre') as String,
      documento: (json['documento'] ?? '').toString(),
      categoria: (json['categoria'] ?? '').toString(),
      edad: json['edad'] is num ? (json['edad'] as num).toInt() : null,
      presente: json['asistencia'] == true,
      observacion: (json['observacion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toApi() {
    return {
      'athleteId': athleteId,
      'asistencia': presente,
      'observacion': observacion,
    };
  }
}
