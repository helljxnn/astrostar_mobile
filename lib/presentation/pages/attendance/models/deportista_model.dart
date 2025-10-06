class Deportista {
  final String nombre;
  final int edad;
  final String categoria;
  bool presente;

  Deportista({
    required this.nombre,
    required this.edad,
    required this.categoria,
    this.presente = false,
  });
}
