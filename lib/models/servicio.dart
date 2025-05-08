/// Clase servicio utilizada para el manejo de datos de servicios en la aplicación
/// es utlizada tanto para la seleccion de citas como para listar los servicios disponibles
/// en el negocio
class Servicio {
  /// Nombre del servicio.
  final String nombre;
  /// Duración del servicio en minutos.
  final int duracion; // en minutos
  /// Precio del servicio.
  final double precio;

  /// Constructor de la clase Servicio.
  Servicio({
    required this.nombre,
    required this.duracion,
    required this.precio,
  });

  /// Método para crear una instancia de Servicio a partir de un mapa JSON.
  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      nombre: json['nombre'],
      duracion: json['duracion'],
      precio: (json['precio'] as num).toDouble(),
    );
  }

  /// Método para convertir una instancia de Servicio a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'duracion': duracion,
      'precio': precio,
    };
  }
}
