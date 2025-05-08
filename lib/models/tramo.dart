/// Clase tramo horario utilizada para establecer los horarios dia a dia
/// de los negocios
class Tramo {
  /// Hora de inicio del tramo horario.
  final String horaInicio;
  /// Hora de fin del tramo horario.
  final String horaFin;

  /// Constructor de la clase Tramo.
  Tramo({
    required this.horaInicio,
    required this.horaFin,
  });

  /// Método para crear una instancia de Tramo a partir de un mapa JSON.
  factory Tramo.fromJson(Map<String, dynamic> json) {
    return Tramo(
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
    );
  }

  /// Método para convertir una instancia de Tramo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'horaInicio': horaInicio,
      'horaFin': horaFin,
    };
  }
}
