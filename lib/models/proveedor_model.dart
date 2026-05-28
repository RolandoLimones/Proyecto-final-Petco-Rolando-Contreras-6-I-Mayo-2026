class Proveedor {
  final String id;
  final String nombre;
  final String contacto;
  final String telefono;
  final String email;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.email,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map, String documentId) {
    return Proveedor(
      id: documentId,
      nombre: map['nombre'] ?? '',
      contacto: map['contacto'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'contacto': contacto,
      'telefono': telefono,
      'email': email,
    };
  }

  Proveedor copyWith({
    String? id,
    String? nombre,
    String? contacto,
    String? telefono,
    String? email,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }
}
