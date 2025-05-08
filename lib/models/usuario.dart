import 'package:cloud_firestore/cloud_firestore.dart';

/// Clase que representa un usuario en la aplicación.
class Usuario {
  /// Identificador único del usuario.
  final String uid;
  /// Identificador del usuario, utilizado como ID incremental.
  final int id; // Nueva propiedad
  /// Nombre del usuario.
  final String nombre;
  /// Apellidos del usuario.
  final String apellidos;
  /// Edad del usuario.
  final int edad;
  /// Teléfono del usuario.
  final String telefono;
  /// Correo electrónico del usuario.
  final String email;
  /// Rol del usuario, puede ser 'cliente' o 'profesional'.
  final String rol; // 'cliente' o 'profesional'
  /// Token de Firebase Cloud Messaging del usuario.
  final List<String>? fcmToken; // Cambiado a List<String>?
  /// Indica si el usuario ha sido eliminado
  final bool deleted;
  /// Fecha de creación del usuario.
  final DateTime createdAt;
  /// Fecha de última actualización del usuario.
  final DateTime updatedAt;
  /// Fecha y hora del último inicio de sesión del usuario.
  final Timestamp? lastLogin;

  /// Constructor de la clase Usuario.
  Usuario({
    required this.uid,
    required this.id, // Añadido al constructor
    required this.nombre,
    required this.apellidos,
    required this.edad,
    required this.telefono,
    required this.email,
    required this.rol,
    this.fcmToken, // Cambiado a List<String>?
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  /// Método para crear una instancia de Usuario a partir de un mapa JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'],
      id: json['id'], // Añadido al método fromJson
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      edad: json['edad'],
      telefono: json['telefono'],
      email: json['email'],
      rol: json['rol'],
      fcmToken: json['fcmToken'] != null
          ? List<String>.from(json['fcmToken'])
          : null, // Convertido a List<String>
      deleted: json['deleted'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      lastLogin: json['lastLogin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id, // Añadido al método toJson
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'telefono': telefono,
      'email': email,
      'rol': rol,
      if (fcmToken != null) 'fcmToken': fcmToken, // Cambiado a List<String>?
      'deleted': deleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastLogin != null) 'lastLogin': lastLogin,
    };
  }
}
