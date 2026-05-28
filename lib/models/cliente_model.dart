class Cliente {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String direccion;
  // Nuevos campos para datos de pago
  final String? tarjetaNumero;
  final String? tarjetaNombre;
  final String? tarjetaExpiry;
  final String? tarjetaCvc;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.direccion,
    this.tarjetaNumero,
    this.tarjetaNombre,
    this.tarjetaExpiry,
    this.tarjetaCvc,
  });

  factory Cliente.fromMap(Map<String, dynamic> map, String documentId) {
    return Cliente(
      id: documentId,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      tarjetaNumero: map['tarjetaNumero'],
      tarjetaNombre: map['tarjetaNombre'],
      tarjetaExpiry: map['tarjetaExpiry'],
      tarjetaCvc: map['tarjetaCvc'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'tarjetaNumero': tarjetaNumero,
      'tarjetaNombre': tarjetaNombre,
      'tarjetaExpiry': tarjetaExpiry,
      'tarjetaCvc': tarjetaCvc,
    };
  }

  Cliente copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? tarjetaNumero,
    String? tarjetaNombre,
    String? tarjetaExpiry,
    String? tarjetaCvc,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      tarjetaNumero: tarjetaNumero ?? this.tarjetaNumero,
      tarjetaNombre: tarjetaNombre ?? this.tarjetaNombre,
      tarjetaExpiry: tarjetaExpiry ?? this.tarjetaExpiry,
      tarjetaCvc: tarjetaCvc ?? this.tarjetaCvc,
    );
  }
}
