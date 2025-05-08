import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nail_ed/models/servicio.dart';

/// Clase que representa una reserva de cita en la aplicación.
class Reserva {
  /// Identificador único de la reserva.
  final String uid; // igual al ID del documento
  /// Identificador incremental de la reserva.
  final int id; // ID incremental
  /// Identificador del cliente que realizó la reserva.
  final String clienteId;
  /// Identificador del negocio donde se realizó la reserva.
  final String negocioId;
  /// Lista de servicios reservados.
  final List<Servicio> servicios;
  /// Fecha y hora de la reserva.
  final DateTime fecha;
  /// Duración total de la reserva en minutos.
  final int duracionTotal;
  /// Costo total de la reserva.
  final double costeTotal;
  /// Estado de la reserva, puede ser 'pendiente', 'confirmada', 'cancelada' o 'completada'.
  final String estado; // 'pendiente', 'confirmada', 'cancelada', 'completada'
  /// Notas adicionales sobre la reserva.
  final String? notas;
  /// Imágenes relacionadas con las notas de la reserva.
  final List<String>? imagenesNotas;
  /// Lista de notificaciones enviadas relacionadas con la reserva.
  final List<String>? notificacionesEnviadas;
  /// Imágenes de los resultados de la reserva.
  final List<String>? imagenesResultado;
  /// Indica si la reserva ha sido elimin
  final bool deleted;
  /// Fecha y hora de creación de la reserva.
  final DateTime createdAt;
  /// Fecha y hora de la última actualización de la reserva.
  final DateTime updatedAt;

  /// Constructor de la clase Reserva.
  Reserva({
    required this.uid,
    required this.id,
    required this.clienteId,
    required this.negocioId,
    required this.servicios,
    required this.fecha,
    required this.duracionTotal,
    required this.costeTotal,
    required this.estado,
    this.notas,
    this.imagenesNotas,
    this.notificacionesEnviadas,
    this.imagenesResultado,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Método para crear una instancia de Reserva a partir de un mapa JSON.
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      uid: json['uid'],
      id: json['id'],
      clienteId: json['clienteId'],
      negocioId: json['negocioId'],
      servicios: (json['servicios'] as List)
          .map((e) => Servicio.fromJson(e as Map<String, dynamic>))
          .toList(),
      fecha: (json['fecha'] as Timestamp).toDate(),
      duracionTotal: json['duracionTotal'],
      costeTotal: (json['costeTotal'] as num).toDouble(),
      estado: json['estado'],
      notas: json['notas'],
      imagenesNotas: (json['imagenesNotas'] as List?)?.map((e) => e.toString()).toList(),
      notificacionesEnviadas: (json['notificacionesEnviadas'] as List?)?.map((e) => e.toString()).toList(),
      imagenesResultado: (json['imagenesResultado'] as List?)?.map((e) => e.toString()).toList(),
      deleted: json['deleted'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Método para convertir una instancia de Reserva a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'clienteId': clienteId,
      'negocioId': negocioId,
      'servicios': servicios.map((e) => e.toJson()).toList(),
      'fecha': Timestamp.fromDate(fecha),
      'duracionTotal': duracionTotal,
      'costeTotal': costeTotal,
      'estado': estado,
      if (notas != null) 'notas': notas,
      if (imagenesNotas != null) 'imagenesNotas': imagenesNotas,
      if (notificacionesEnviadas != null) 'notificacionesEnviadas': notificacionesEnviadas,
      if (imagenesResultado != null) 'imagenesResultado': imagenesResultado,
      'deleted': deleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
