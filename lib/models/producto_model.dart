class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String? imagenUrl;
  final bool activo;
  final String creadorId;
  final String? sucursalId;
  final String? proveedorId;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.imagenUrl,
    this.activo = true,
    required this.creadorId,
    this.sucursalId,
    this.proveedorId,
  });

  factory Producto.fromMap(Map<String, dynamic> map, String documentId) {
    return Producto(
      id: documentId,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] is num) ? (map['precio'] as num).toDouble() : 0.0,
      categoria: map['categoria'] ?? '',
      imagenUrl: map['imagenUrl'],
      activo: map['activo'] ?? true,
      creadorId: map['creadorId'] ?? '',
      sucursalId: map['sucursalId'],
      proveedorId: map['proveedorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'activo': activo,
      'creadorId': creadorId,
      if (sucursalId != null) 'sucursalId': sucursalId,
      if (proveedorId != null) 'proveedorId': proveedorId,
    };
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? categoria,
    String? imagenUrl,
    bool? activo,
    String? creadorId,
    String? sucursalId,
    String? proveedorId,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      activo: activo ?? this.activo,
      creadorId: creadorId ?? this.creadorId,
      sucursalId: sucursalId ?? this.sucursalId,
      proveedorId: proveedorId ?? this.proveedorId,
    );
  }
}
