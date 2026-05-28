class Sucursal {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String horario;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.horario,
  });

  factory Sucursal.fromMap(Map<String, dynamic> map, String documentId) {
    return Sucursal(
      id: documentId,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      horario: map['horario'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'horario': horario,
    };
  }

  Sucursal copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? horario,
  }) {
    return Sucursal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      horario: horario ?? this.horario,
    );
  }
}
