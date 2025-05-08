import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nail_ed/models/tramo.dart';
import 'package:nail_ed/models/servicio.dart';

/// Clase que representa un negocio en la aplicación.
class Negocio {
  /// Identificador único del negocio.
  final String uid;
  /// Identificador del negocio.
  final int id;
  /// Nombre del negocio.
  final String nombre;
  /// Ubicación del negocio.
  final String ubicacion;
  /// URL de la imagen del negocio.
  final String? image;
  /// Lista de servicios ofrecidos por el negocio.
  final List<Servicio> servicios;
  /// Horarios de atención del negocio.
  final Map<String, Tramo> horarios;
  /// Intervalo de citas en minutos.
  final int? intervaloCitas;
  /// Días no disponibles para citas.
  final List<String>? diasNoDisponibles;
  /// Descripción del negocio.
  final String descripcionNegocio;
  /// Términos y condiciones del negocio.
  final String terminosCondiciones;
  /// Margen de cancelacion permitido, en horas
  final int cancelacionHoras;
  /// Indica si el negocio está eliminado.
  final bool deleted;
  /// Fecha de creación del negocio.
  final DateTime createdAt;
  /// Fecha de última actualización del negocio.
  final DateTime updatedAt;

  /// Constructor de la clase Negocio.
  Negocio({
    required this.uid,
    required this.id,
    required this.nombre,
    required this.ubicacion,
    this.image,
    required this.servicios,
    required this.horarios,
    this.intervaloCitas,
    this.diasNoDisponibles,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    required this.descripcionNegocio,
    required this.terminosCondiciones,
    required this.cancelacionHoras,
  });

  /// Método para crear una instancia de Negocio a partir de un mapa JSON.
  factory Negocio.fromJson(Map<String, dynamic> json) {
    return Negocio(
      uid: json['uid'],
      id: json['id'],
      nombre: json['nombre'],
      ubicacion: json['ubicacion'],
      image: json['image'],
      servicios: (json['servicios'] as List)
          .map((e) => Servicio.fromJson(e as Map<String, dynamic>))
          .toList(),
      horarios: (json['horarios'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Tramo.fromJson(value)),
      ),
      intervaloCitas: json['intervaloCitas'],
      diasNoDisponibles: (json['diasNoDisponibles'] as List?)?.map((e) => e.toString()).toList(),
      deleted: json['deleted'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      descripcionNegocio: json['descripcionNegocio'] as String? ?? '',
      terminosCondiciones: json['terminosCondiciones'] as String? ?? '',
      cancelacionHoras: (json['cancelacionHoras'] as num?)?.toInt() ?? 24,
    );
  }

  /// Método para convertir una instancia de Negocio a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'nombre': nombre,
      'ubicacion': ubicacion,
      if (image != null) 'image': image,
      'servicios': servicios.map((e) => e.toJson()).toList(),
      'horarios': horarios.map((key, value) => MapEntry(key, value.toJson())),
      if (intervaloCitas != null) 'intervaloCitas': intervaloCitas,
      if (diasNoDisponibles != null) 'diasNoDisponibles': diasNoDisponibles,
      'deleted': deleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'descripcionNegocio': descripcionNegocio,
      'terminosCondiciones': terminosCondiciones,
      'cancelacionHoras': cancelacionHoras,
    };
  }
}
