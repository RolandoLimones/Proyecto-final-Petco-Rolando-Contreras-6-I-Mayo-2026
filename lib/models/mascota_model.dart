class Mascota {
  final String id;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;
  final double? peso;
  final String clienteId;

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    this.peso,
    required this.clienteId,
  });

  factory Mascota.fromMap(Map<String, dynamic> map, String documentId) {
    return Mascota(
      id: documentId,
      nombre: map['nombre'] ?? '',
      especie: map['especie'] ?? '',
      raza: map['raza'] ?? '',
      edad: map['edad'] ?? 0,
      peso: (map['peso'] is num) ? (map['peso'] as num).toDouble() : null,
      clienteId: map['clienteId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'edad': edad,
      'peso': peso,
      'clienteId': clienteId,
    };
  }

  Mascota copyWith({
    String? id,
    String? nombre,
    String? especie,
    String? raza,
    int? edad,
    double? peso,
    String? clienteId,
  }) {
    return Mascota(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      edad: edad ?? this.edad,
      peso: peso ?? this.peso,
      clienteId: clienteId ?? this.clienteId,
    );
  }
}
