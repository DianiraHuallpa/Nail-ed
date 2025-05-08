/// Clase registro utilizada para el manejo de datos de registro de usuarios
class RegistroData {
  /// Rol del usuario, puede ser 'cliente' o 'profesional'.
  String rol; // 'cliente' | 'profesional';
  /// Nombre del usuario.
  String? nombre;
  /// Apellidos del usuario.
  String? apellidos;
  /// Edad del usuario.
  String? edad;
  /// Teléfono del usuario.
  String? telefono;
  /// Correo electrónico del usuario.
  String? email;
  /// Contraseña del usuario.
  String? password;
  /// Nombre del negocio, solo para profesionales.
  String? nombreNegocio;
  /// Ubicación del negocio, solo para profesionales.
  String? ubicacionNegocio;

  /// Convierte la instancia de RegistroData a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'rol': rol,
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'telefono': telefono,
      'email': email,
      'password': password,
      'nombreNegocio': nombreNegocio ?? '',
      'ubicacionNegocio': ubicacionNegocio ?? '',
    };
  }

  /// Constructor de la clase RegistroData.
  RegistroData({required this.rol});
}