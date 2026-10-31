import 'dart:async';
import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'rutina.dart';

class PantallaEntrenoVivo extends StatefulWidget {
  final int rutinaId; // Recibimos el ID desde el Dashboard

  const PantallaEntrenoVivo({super.key, required this.rutinaId});

  @override
  State<PantallaEntrenoVivo> createState() => _PantallaEntrenoVivoState();
}

class _PantallaEntrenoVivoState extends State<PantallaEntrenoVivo> {
  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  Rutina? _rutina;
  bool _cargando = true;
  String _error = '';

  // Variables del Cronómetro
  Timer? _timer;
  int _segundosActivos = 0;
  bool _entrenoPausado = false;

  // Mapa para rastrear las series completadas: { indiceEjercicio : [true, false, true...] }
  final Map<int, List<bool>> _seriesCompletadas = {};

  @override
  void initState() {
    super.initState();
    _cargarDetalleRutina();
  }

  @override
  void dispose() {
    _timer?.cancel(); // ¡Muy importante para evitar fugas de memoria!
    super.dispose();
  }

  void _cargarDetalleRutina() async {
    try {
      final rutina = await ApiServicio.obtenerRutinaPorId(widget.rutinaId);
      setState(() {
        _rutina = rutina;
        _cargando = false;
        _inicializarChecks(rutina);
        _iniciarCronometro();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  // Prepara la lista de "checks" en falso (vacíos) para cada serie de cada ejercicio
  void _inicializarChecks(Rutina rutina) {
    if (rutina.ejercicios != null) {
      for (int i = 0; i < rutina.ejercicios!.length; i++) {
        int cantidadSeries = rutina.ejercicios![i]['series'] ?? 0;
        _seriesCompletadas[i] = List.generate(cantidadSeries, (index) => false);
      }
    }
  }

  void _iniciarCronometro() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_entrenoPausado) {
        setState(() {
          _segundosActivos++;
        });
      }
    });
  }

  String _formatearTiempo(int segundosTotales) {
    int horas = segundosTotales ~/ 3600;
    int minutos = (segundosTotales % 3600) ~/ 60;
    int segundos = segundosTotales % 60;

    if (horas > 0) {
      return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
    }
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: greenAccent)),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(backgroundColor: bgDark, elevation: 0),
        body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent))),
      );
    }

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(
          _rutina!.nombre,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(_entrenoPausado ? Icons.play_arrow : Icons.pause, color: greenAccent),
            onPressed: () {
              setState(() {
                _entrenoPausado = !_entrenoPausado;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // CABECERA DEL CRONÓMETRO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: cardDark,
              border: const Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              children: [
                Text(
                  _formatearTiempo(_segundosActivos),
                  style: TextStyle(
                    color: _entrenoPausado ? textMuted : greenAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  _entrenoPausado ? 'EN PAUSA' : 'TIEMPO ACTIVO',
                  style: TextStyle(color: textMuted, fontSize: 12, letterSpacing: 2),
                )
              ],
            ),
          ),

          // LISTA DE EJERCICIOS
          Expanded(
            child: _rutina!.ejercicios == null || _rutina!.ejercicios!.isEmpty
                ? Center(child: Text('No hay ejercicios en esta rutina', style: TextStyle(color: textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rutina!.ejercicios!.length,
                    itemBuilder: (context, indexEjercicio) {
                      final ejercicio = _rutina!.ejercicios![indexEjercicio];
                      final cantidadSeries = ejercicio['series'] ?? 0;
                      final repsObjetivo = ejercicio['reps'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                '${indexEjercicio + 1}. ${ejercicio['nombre']}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Cabecera de la tabla de series
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(width: 40, child: Text('SERIE', style: TextStyle(color: textMuted, fontSize: 12))),
                                  Expanded(child: Center(child: Text('OBJETIVO', style: TextStyle(color: textMuted, fontSize: 12)))),
                                  SizedBox(width: 40, child: Icon(Icons.check, color: textMuted, size: 16)),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            // Filas de las series
                            ...List.generate(cantidadSeries, (indexSerie) {
                              bool completada = _seriesCompletadas[indexEjercicio]![indexSerie];

                              return Container(
                                color: completada ? greenAccent.withOpacity(0.1) : Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text('${indexSerie + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            '$repsObjetivo reps',
                                            style: TextStyle(
                                              color: completada ? Colors.white54 : Colors.white,
                                              decoration: completada ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _seriesCompletadas[indexEjercicio]![indexSerie] = !completada;
                                          });
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: completada ? greenAccent : Colors.transparent,
                                            border: Border.all(color: completada ? greenAccent : Colors.white30),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: completada
                                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // BOTÓN DE FINALIZAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí iría la lógica para enviar el progreso a la Base de Datos
                  _timer?.cancel();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('FINALIZAR ENTRENAMIENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}