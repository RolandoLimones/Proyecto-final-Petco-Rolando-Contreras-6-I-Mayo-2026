// lib/models/cart_item_model.dart
class CartItem {
  final String id;
  final String nombre;
  final double precio;
  int cantidad;
  final String? imagenUrl;

  CartItem({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.imagenUrl,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      cantidad: map['cantidad'] ?? 1,
      imagenUrl: map['imagenUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
    };
  }

  CartItem copyWith({
    String? id,
    String? nombre,
    double? precio,
    int? cantidad,
    String? imagenUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
