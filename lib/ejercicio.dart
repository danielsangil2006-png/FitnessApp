class Ejercicio {
  final int? id;
  final String nombre;
  final String? grupoMuscular;
  final String? urlVideoTecnica;
  final String? urlAnimacion; // Nuevo campo para el GIF

  Ejercicio({
    this.id, 
    required this.nombre, 
    this.grupoMuscular, 
    this.urlVideoTecnica,
    this.urlAnimacion,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    // ¡ESTA LÍNEA ES LA CLAVE PARA EL DIAGNÓSTICO!
    print('JSON CRUDO DEL EJERCICIO: $json'); 

    return Ejercicio(
      // Intentamos leer 'id' y también 'idEjercicio' por si acaso
      id: json['id'] != null 
          ? int.tryParse(json['id'].toString()) 
          : (json['idEjercicio'] != null ? int.tryParse(json['idEjercicio'].toString()) : null),
      nombre: json['nombre'] ?? 'Ejercicio sin nombre',
      grupoMuscular: json['grupoMuscular'],
      urlVideoTecnica: json['urlVideoTecnica'],
      urlAnimacion: json['urlAnimacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'grupoMuscular': grupoMuscular,
      'urlVideoTecnica': urlVideoTecnica,
      'urlAnimacion': urlAnimacion,
    };
  }
}