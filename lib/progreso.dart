class Progreso {
  final int? id;
  final int rutinaId;
  final int duracionSegundos;
  final double pesoTotalLevantado;
  final String? fecha;

  Progreso({
    this.id,
    required this.rutinaId,
    required this.duracionSegundos,
    required this.pesoTotalLevantado,
    this.fecha,
  });

  factory Progreso.fromJson(Map<String, dynamic> json) {
    return Progreso(
      id: json['id'],
      rutinaId: json['rutina']?['id'] ?? json['rutinaId'] ?? 0,
      duracionSegundos: json['duracionSegundos'] ?? 0,
      pesoTotalLevantado: (json['pesoTotalLevantado'] ?? 0).toDouble(),
      fecha: json['fecha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rutinaId': rutinaId,
      'duracionSegundos': duracionSegundos,
      'pesoTotalLevantado': pesoTotalLevantado,
    };
  }
}