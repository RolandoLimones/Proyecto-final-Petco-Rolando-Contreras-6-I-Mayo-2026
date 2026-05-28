class Pedido {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final DateTime fecha;
  final double total;
  final String estado;
  final String numeroTarjeta;
  final String direccionEnvio;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.fecha,
    required this.total,
    required this.estado,
    required this.numeroTarjeta,
    required this.direccionEnvio,
  });

  factory Pedido.fromMap(Map<String, dynamic> map, String documentId) {
    return Pedido(
      id: documentId,
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
      total: (map['total'] is num) ? (map['total'] as num).toDouble() : 0.0,
      estado: map['estado'] ?? 'Pendiente',
      numeroTarjeta: map['numeroTarjeta'] ?? '',
      direccionEnvio: map['direccionEnvio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'estado': estado,
      'numeroTarjeta': numeroTarjeta,
      'direccionEnvio': direccionEnvio,
    };
  }

  Pedido copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    DateTime? fecha,
    double? total,
    String? estado,
    String? numeroTarjeta,
    String? direccionEnvio,
  }) {
    return Pedido(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      numeroTarjeta: numeroTarjeta ?? this.numeroTarjeta,
      direccionEnvio: direccionEnvio ?? this.direccionEnvio,
    );
  }
}
