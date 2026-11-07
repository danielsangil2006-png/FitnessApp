import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rutina.dart';

class ApiServicio {
  // ⚠️ IMPORTANTE: Pon la IP de tu computadora aquí (ej. 192.168.1.5)
static const String ipBase = "http://192.168.1.8:8081/api";  // Correcto: Termina en /api/kronos
static const String baseUrl = "http://192.168.1.8:8081/api/kronos"; 

  

  static Future<List<Rutina>> obtenerMisRutinas() async {
    final response = await http.get(Uri.parse('$ipBase/rutinas'));
    if (response.statusCode == 200) {
      Iterable lista = jsonDecode(response.body);
      return lista.map((modelo) => Rutina.fromJson(modelo)).toList();
    } else {
      throw Exception('Error al cargar las rutinas');
    }
  }

  static Future<Rutina> obtenerRutinaPorId(int id) async {
    final response = await http.get(Uri.parse('$ipBase/rutinas/$id'));
    if (response.statusCode == 200) {
      return Rutina.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo con código');
    }
  }

  // 1. MÉTODO RESTAURADO PARA LA PANTALLA CREAR RUTINA
  static Future<bool> crearRutina(Map nuevaRutina) async {
    try {
      final response = await http.post(
        Uri.parse('$ipBase/rutinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(nuevaRutina),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 2. TIPO "List" SIMPLE SIN SÍMBOLOS COMPLEJOS
  static Future<bool> guardarProgreso(int rutinaId, int tiempoSegundos, List seriesLog) async {
    try {
      final response = await http.post(
        Uri.parse('$ipBase/progresos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rutinaId': rutinaId,
          'usuarioId': 1,
          'tiempoSegundos': tiempoSegundos,
          'fecha': DateTime.now().toIso8601String(),
          'seriesDetalle': seriesLog, 
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. TIPO "dynamic" PARA EVITAR EL ERROR "Future?>"
  static Future<dynamic> obtenerUltimoProgreso() async {
    try {
      final response = await http.get(Uri.parse('$ipBase/progresos'));
      if (response.statusCode == 200) {
        List<dynamic> progresos = jsonDecode(response.body);
        if (progresos.isNotEmpty) {
          progresos.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
          return progresos.first; 
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> eliminarRutina(int id) async {
    try {
      final response = await http.delete(Uri.parse('$ipBase/rutinas/$id'));
      // Spring Boot suele devolver 200 (OK) o 204 (No Content) al borrar exitosamente
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> editarRutina(int id, Map<String, dynamic> rutinaData) async {
    try {
      final response = await http.put(
        Uri.parse('$ipBase/rutinas/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rutinaData),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error al editar rutina: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$ipBase/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registrarUsuario(Map<String, dynamic> datos) async {
    try {
      final url = Uri.parse('$ipBase/auth/registro');
      print('🚀 Intentando enviar datos a: $url'); // Nos dirá si la IP está mal escrita
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      
      print('✅ El servidor respondió con código: ${response.statusCode}');
      print('📄 Respuesta del servidor: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ ERROR CRÍTICO EN REGISTRO: $e'); // ¡AQUÍ ESTÁ EL CULPABLE!
      return false;
    }
  }

}