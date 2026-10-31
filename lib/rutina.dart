class Rutina {
  int? id;
  String nombre;
  String descripcion;
  bool activa;
  int? usuarioId;
  List<dynamic>? ejercicios; // ¡Aquí está la variable que faltaba!

  Rutina({
    this.id,
    required this.nombre,
    required this.descripcion,
    this.activa = true,
    this.usuarioId,
    this.ejercicios,
  });

  // Convertir el JSON que viene de Spring Boot a un objeto Flutter
  factory Rutina.fromJson(Map<String, dynamic> json) {
    return Rutina(
      id: json['id'],
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      activa: json['activa'] ?? true,
      usuarioId: json['usuarioId'],
      ejercicios: json['ejercicios'] != null 
          ? List<dynamic>.from(json['ejercicios']) 
          : [],
    );
  }

  // Convertir el objeto Flutter a JSON para enviarlo a Spring Boot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activa': activa,
      'usuarioId': usuarioId,
      'ejercicios': ejercicios,
    };
  }
}