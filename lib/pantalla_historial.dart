import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_servicio.dart'; 
import 'rutina.dart'; 

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  List<dynamic> _historial = [];
  List<Rutina> _rutinas = []; 
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final rutinas = await ApiServicio.obtenerMisRutinas();
      final response = await http.get(Uri.parse('${ApiServicio.ipBase}/progresos'));
      
      if (response.statusCode == 200) {
        List<dynamic> datos = jsonDecode(response.body);
        datos.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
        
        if (mounted) {
          setState(() {
            _rutinas = rutinas; 
            _historial = datos; 
            _cargando = false;
          });
        }
      } else {
        if (mounted) setState(() => _cargando = false);
      }
    } catch (e) {
      print('Error cargando historial: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Fecha desconocida';
    try {
      DateTime fecha = DateTime.parse(fechaIso);
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // 👇 NUEVO MÉTODO PARA MOSTRAR EL MODAL CON EL DESGLOSE DE PESOS 👇
  void _mostrarDetalleSesion(Map<String, dynamic> sesion, String nombreRutina) {
    final List series = sesion['seriesDetalle'] ?? [];
    if (series.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay series guardadas en esta sesión', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orangeAccent));
      return;
    }

    // Buscamos la rutina real para obtener los nombres de los ejercicios
    Rutina? rutinaReal;
    try {
      rutinaReal = _rutinas.firstWhere((r) => r.id == sesion['rutinaId']);
    } catch (e) {
      rutinaReal = null;
    }

    // Agrupamos las series por cada ejercicio para organizarlas visualmente
    Map<int, List<dynamic>> seriesAgrupadas = {};
    for (var s in series) {
      int ejIndex = s['ejercicioIndex'] ?? 0;
      if (!seriesAgrupadas.containsKey(ejIndex)) {
        seriesAgrupadas[ejIndex] = [];
      }
      seriesAgrupadas[ejIndex]!.add(s);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7, // El modal ocupará el 70% de la pantalla
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(nombreRutina, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Desglose de pesos levantados', style: TextStyle(color: greenAccent, fontSize: 14)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: seriesAgrupadas.keys.length,
                    itemBuilder: (context, index) {
                      int ejIndex = seriesAgrupadas.keys.elementAt(index);
                      List<dynamic> seriesDelEjercicio = seriesAgrupadas[ejIndex]!;
                      
                      // Extraemos el nombre real del ejercicio si la rutina existe
                      String nombreEjercicio = 'Ejercicio ${ejIndex + 1}';
                      if (rutinaReal != null && rutinaReal.ejercicios != null && rutinaReal.ejercicios!.length > ejIndex) {
                        nombreEjercicio = rutinaReal.ejercicios![ejIndex]['nombre'] ?? nombreEjercicio;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombreEjercicio, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 40, child: Text('SERIE', style: TextStyle(color: textMuted, fontSize: 12))),
                                Text('PESO LOGRADO', style: TextStyle(color: textMuted, fontSize: 12)),
                              ],
                            ),
                            const Divider(color: Colors.white12),
                            ...seriesDelEjercicio.map((serie) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 40, child: Text('${serie['numeroSerie']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text('${serie['pesoKg']} Kg', style: TextStyle(color: greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Text('Historial de Entrenamientos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: greenAccent))
          : _historial.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: textMuted, size: 64),
                      const SizedBox(height: 16),
                      Text('No hay entrenamientos guardados', style: TextStyle(color: textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: greenAccent,
                  backgroundColor: cardDark,
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final sesion = _historial[index];
                      final int segundos = sesion['tiempoSegundos'] ?? 0;
                      final List series = sesion['seriesDetalle'] ?? [];

                      String nombreRutina = 'Rutina #${sesion['rutinaId']}';
                      try {
                        if (_rutinas.isNotEmpty) {
                          final rutinaEncontrada = _rutinas.firstWhere((r) => r.id == sesion['rutinaId']);
                          nombreRutina = rutinaEncontrada.nombre;
                        }
                      } catch (e) {
                        // Respaldo
                      }

                      // 👇 AQUÍ CONVERTIMOS LA TARJETA EN UN BOTÓN INTERACTIVO 👇
                      return GestureDetector(
                        onTap: () => _mostrarDetalleSesion(sesion, nombreRutina),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: textMuted, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatearFecha(sesion['fecha']),
                                        style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nombreRutina,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, color: greenAccent, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${segundos ~/ 60}m ${segundos % 60}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.fitness_center, color: textMuted, size: 14),
                                      const SizedBox(width: 4),
                                      Text('${series.length} series', style: TextStyle(color: textMuted, fontSize: 12)),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}