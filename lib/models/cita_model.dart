// lib/models/cita_model.dart
class Cita {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String mascotaId;
  final String mascotaNombre;
  final String fecha;
  final String hora;
  final String motivoTipo;
  final double precio;
  final String metodoPago;
  final String estadoPago;
  final String estado;
  final String sucursalId; // new
  final String sucursalNombre; // new

  Cita({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.mascotaId,
    required this.mascotaNombre,
    required this.fecha,
    required this.hora,
    required this.motivoTipo,
    required this.precio,
    required this.metodoPago,
    required this.estadoPago,
    this.estado = 'Pendiente',
    required this.sucursalId,
    required this.sucursalNombre,
  });

  factory Cita.fromMap(Map<String, dynamic> map, String documentId) {
    return Cita(
      id: documentId,
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      mascotaId: map['mascotaId'] ?? '',
      mascotaNombre: map['mascotaNombre'] ?? '',
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
      motivoTipo: map['motivoTipo'] ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      metodoPago: map['metodoPago'] ?? '',
      estadoPago: map['estadoPago'] ?? '',
      estado: map['estado'] ?? 'Pendiente',
      sucursalId: map['sucursalId'] ?? '',
      sucursalNombre: map['sucursalNombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'mascotaId': mascotaId,
      'mascotaNombre': mascotaNombre,
      'fecha': fecha,
      'hora': hora,
      'motivoTipo': motivoTipo,
      'precio': precio,
      'metodoPago': metodoPago,
      'estadoPago': estadoPago,
      'estado': estado,
      'sucursalId': sucursalId,
      'sucursalNombre': sucursalNombre,
    };
  }

  Cita copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? mascotaId,
    String? mascotaNombre,
    String? fecha,
    String? hora,
    String? motivoTipo,
    double? precio,
    String? metodoPago,
    String? estadoPago,
    String? estado,
    String? sucursalId,
    String? sucursalNombre,
  }) {
    return Cita(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      mascotaId: mascotaId ?? this.mascotaId,
      mascotaNombre: mascotaNombre ?? this.mascotaNombre,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivoTipo: motivoTipo ?? this.motivoTipo,
      precio: precio ?? this.precio,
      metodoPago: metodoPago ?? this.metodoPago,
      estadoPago: estadoPago ?? this.estadoPago,
      estado: estado ?? this.estado,
      sucursalId: sucursalId ?? this.sucursalId,
      sucursalNombre: sucursalNombre ?? this.sucursalNombre,
    );
  }
}
