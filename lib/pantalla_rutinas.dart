import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Servicio encargado de conectar con las rutas de rutinas en Spring Boot
class RutinaService {
  // Asegúrate de usar tu IP local exacta o localhost si usas adb forward
  static const String baseUrl = "http://192.168.1.8:8081/api/rutinas";

  // Obtener rutinas del usuario
  static Future<List<dynamic>> obtenerRutinasPorUsuario(int usuarioId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/usuario/$usuarioId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Error al conectar con el servidor de rutinas: $e");
    }
    return []; // Retorna lista vacía si hay error para que la UI no colapse
  }
}

// Pantalla principal del Historial de Rutinas
class PantallaHistorialRutinas extends StatelessWidget {
  final int usuarioId;

  const PantallaHistorialRutinas({Key? key, required this.usuarioId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color fondoOscuro = Color(0xFF0b0d11);
    const Color superficieOscura = Color(0xFF151922);
    const Color acentoCian = Color(0xFF00E5FF);
    const Color textoClaro = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text(
          "Historial de Rutinas",
          style: TextStyle(color: textoClaro, fontWeight: FontWeight.bold),
        ),
        backgroundColor: superficieOscura,
        iconTheme: const IconThemeData(color: acentoCian),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: RutinaService.obtenerRutinasPorUsuario(usuarioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: acentoCian),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error al cargar el historial de rutinas.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  );
                }

                final rutinas = snapshot.data ?? [];

                if (rutinas.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "Aún no hay entrenamientos registrados.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: rutinas.length,
                  itemBuilder: (context, index) {
                    final rutina = rutinas[index];
                    final int rutinaId = rutina['id'] ?? 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: superficieOscura,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10, width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          // Feedback visual de intento
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Iniciando rutina...", style: TextStyle(color: Colors.white)),
                              backgroundColor: acentoCian,
                              duration: Duration(seconds: 1),
                            ),
                          );

                          try {
                            final response = await http.post(
                              Uri.parse('${RutinaService.baseUrl}/iniciar'),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "rutinaId": rutinaId,
                                "usuarioId": usuarioId,
                              }),
                            ).timeout(const Duration(seconds: 5));

                            if (response.statusCode == 200 || response.statusCode == 201) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("¡Rutina iniciada con éxito!", style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              // Muestra el código exacto y el mensaje que envía el servidor en la pantalla
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error ${response.statusCode}: ${response.body}", style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Excepción de red: $e", style: const TextStyle(color: Colors.white)),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rutina['nombre'] ?? 'Rutina sin nombre',
                                      style: const TextStyle(
                                        color: textoClaro,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      rutina['descripcion'] ?? 'Sin descripción adicional',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: acentoCian.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: acentoCian,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}