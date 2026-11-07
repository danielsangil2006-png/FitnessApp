import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PantallaProgreso extends StatefulWidget {
  final int usuarioId;

  const PantallaProgreso({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _PantallaProgresoState createState() => _PantallaProgresoState();
}

class _PantallaProgresoState extends State<PantallaProgreso> {
  static const String baseUrl = "http://192.168.1.8:8081/api/progresos";

  Future<List<dynamic>> _cargarProgresos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuario/${widget.usuarioId}'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Error al cargar progresos: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    const Color fondoOscuro = Color(0xFF0b0d11);
    const Color superficieOscura = Color(0xFF151922);
    const Color acentoCian = Color(0xFF00E5FF);
    const Color textoClaro = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text("Tu Progreso", style: TextStyle(color: textoClaro, fontWeight: FontWeight.bold)),
        backgroundColor: superficieOscura,
        iconTheme: const IconThemeData(color: acentoCian),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _cargarProgresos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acentoCian));
          }

          final progresos = snapshot.data ?? [];

          if (progresos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No hay registros de progreso aún.\nCompleta entrenamientos para ver tu evolución de sobrecarga.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: progresos.length,
            itemBuilder: (context, index) {
              final prog = progresos[index];
              return ListTile(
                tileColor: superficieOscura,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text("Entrenamiento del ${prog['fecha'] ?? ''}", style: const TextStyle(color: textoClaro)),
                subtitle: Text("Duración: ${prog['tiempoSegundos'] ?? 0} segundos", style: const TextStyle(color: Colors.white60)),
              );
            },
          );
        },
      ),
    );
  }
}