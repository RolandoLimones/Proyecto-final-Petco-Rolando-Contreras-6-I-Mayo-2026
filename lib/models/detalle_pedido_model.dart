class DetallePedido {
  final String id;
  final String pedidoId;
  final String productoId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final String? productoImagenUrl; // NUEVO

  DetallePedido({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    this.productoImagenUrl,
  });

  double get subtotal => precioUnitario * cantidad;

  factory DetallePedido.fromMap(Map<String, dynamic> map, String documentId) {
    return DetallePedido(
      id: documentId,
      pedidoId: map['pedidoId'] ?? '',
      productoId: map['productoId'] ?? '',
      productoNombre: map['productoNombre'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precioUnitario: (map['precioUnitario'] is num)
          ? (map['precioUnitario'] as num).toDouble()
          : 0.0,
      productoImagenUrl: map['productoImagenUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      if (productoImagenUrl != null) 'productoImagenUrl': productoImagenUrl,
    };
  }

  DetallePedido copyWith({
    String? id,
    String? pedidoId,
    String? productoId,
    String? productoNombre,
    int? cantidad,
    double? precioUnitario,
    String? productoImagenUrl,
  }) {
    return DetallePedido(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      productoImagenUrl: productoImagenUrl ?? this.productoImagenUrl,
    );
  }
}
