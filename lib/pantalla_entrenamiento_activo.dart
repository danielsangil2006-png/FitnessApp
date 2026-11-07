import 'dart:async';
import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'rutina.dart';

class PantallaEntrenoVivo extends StatefulWidget {
  final int rutinaId;
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

  Timer? _timer;
  int _segundosActivos = 0;
  bool _entrenoPausado = false;

  final Map<int, List<bool>> _seriesCompletadas = {};
  final Map<int, List<TextEditingController>> _controladoresPeso = {};

  @override
  void initState() {
    super.initState();
    _cargarDetalleRutina();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controladoresPeso.forEach((key, controladores) {
      for (var controlador in controladores) {
        controlador.dispose();
      }
    });
    super.dispose();
  }

  void _cargarDetalleRutina() async {
    try {
      final rutina = await ApiServicio.obtenerRutinaPorId(widget.rutinaId);
      setState(() {
        _rutina = rutina;
        _cargando = false;
        _inicializarChecksYControladores(rutina);
        _iniciarCronometro();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _inicializarChecksYControladores(Rutina rutina) {
    if (rutina.ejercicios != null) {
      for (int i = 0; i < rutina.ejercicios!.length; i++) {
        int cantidadSeries = rutina.ejercicios![i]['series'] ?? 0;
        _seriesCompletadas[i] = List.generate(cantidadSeries, (index) => false);
        _controladoresPeso[i] = List.generate(cantidadSeries, (index) => TextEditingController());
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
      return Scaffold(backgroundColor: bgDark, body: Center(child: CircularProgressIndicator(color: greenAccent)));
    }
    if (_error.isNotEmpty) {
      return Scaffold(backgroundColor: bgDark, appBar: AppBar(backgroundColor: bgDark, elevation: 0), body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent))));
    }

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(_rutina!.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_entrenoPausado ? Icons.play_arrow : Icons.pause, color: greenAccent),
            onPressed: () => setState(() => _entrenoPausado = !_entrenoPausado),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: cardDark, border: const Border(bottom: BorderSide(color: Colors.white12))),
              child: Column(
                children: [
                  Text(
                    _formatearTiempo(_segundosActivos),
                    style: TextStyle(color: _entrenoPausado ? textMuted : greenAccent, fontSize: 48, fontWeight: FontWeight.bold, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  Text(_entrenoPausado ? 'EN PAUSA' : 'TIEMPO ACTIVO', style: TextStyle(color: textMuted, fontSize: 12, letterSpacing: 2))
                ],
              ),
            ),
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
                          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('${indexEjercicio + 1}. ${ejercicio['nombre']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    SizedBox(width: 30, child: Text('SERIE', style: TextStyle(color: textMuted, fontSize: 12))),
                                    Expanded(child: Center(child: Text('OBJETIVO', style: TextStyle(color: textMuted, fontSize: 12)))),
                                    SizedBox(width: 60, child: Center(child: Text('PESO', style: TextStyle(color: textMuted, fontSize: 12)))),
                                    const SizedBox(width: 12),
                                    SizedBox(width: 32, child: Center(child: Icon(Icons.check, color: textMuted, size: 16))),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              ...List.generate(cantidadSeries, (indexSerie) {
                                bool completada = _seriesCompletadas[indexEjercicio]![indexSerie];
                                return Container(
                                  color: completada ? greenAccent.withOpacity(0.1) : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 30, child: Text('${indexSerie + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                        Expanded(
                                          child: Center(
                                            child: Text('$repsObjetivo reps', style: TextStyle(color: completada ? Colors.white54 : Colors.white, decoration: completada ? TextDecoration.lineThrough : null)),
                                          ),
                                        ),
                                        Container(
                                          width: 60, height: 35, margin: const EdgeInsets.only(right: 12),
                                          child: TextField(
                                            controller: _controladoresPeso[indexEjercicio]![indexSerie],
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                            decoration: InputDecoration(
                                              hintText: 'Kg', hintStyle: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 12),
                                              contentPadding: EdgeInsets.zero, filled: true, fillColor: bgDark,
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // VALIDACIÓN: Solo exige peso si intentas marcar como completada
                                            if (!completada) {
                                              if (_controladoresPeso[indexEjercicio]![indexSerie].text.trim().isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('⚠️ Ingresa el peso (Kg) antes de completar la serie', style: TextStyle(color: Colors.white)),
                                                    backgroundColor: Colors.orangeAccent,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                return; // Corta la ejecución
                                              }
                                            }
                                            
                                            setState(() => _seriesCompletadas[indexEjercicio]![indexSerie] = !completada);
                                          },
                                          child: Container(
                                            width: 32, height: 32,
                                            decoration: BoxDecoration(color: completada ? greenAccent : Colors.transparent, border: Border.all(color: completada ? greenAccent : Colors.white30), borderRadius: BorderRadius.circular(8)),
                                            child: completada ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    _timer?.cancel(); 
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Guardando...', style: TextStyle(color: Colors.white)), backgroundColor: cardDark));

                    // TIPO LIST SIMPLE PARA EVITAR ERRORES DE SINTAXIS AL COPIAR
                    List seriesLog = [];
                    _seriesCompletadas.forEach((indexEjercicio, series) {
                      for (int i = 0; i < series.length; i++) {
                        if (series[i]) { 
                          String textoPeso = _controladoresPeso[indexEjercicio]![i].text;
                          double pesoLevantado = double.tryParse(textoPeso) ?? 0.0;
                          seriesLog.add({'ejercicioIndex': indexEjercicio, 'numeroSerie': i + 1, 'pesoKg': pesoLevantado});
                        }
                      }
                    });

                    bool exito = await ApiServicio.guardarProgreso(widget.rutinaId, _segundosActivos, seriesLog);

                    if (exito && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('¡Entrenamiento guardado!', style: TextStyle(color: Colors.white)), backgroundColor: greenAccent));
                      Navigator.pop(context); 
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar el progreso'), backgroundColor: Colors.redAccent));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: greenAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('FINALIZAR ENTRENAMIENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}