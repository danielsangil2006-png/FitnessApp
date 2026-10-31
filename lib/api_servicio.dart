import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ejercicio.dart';
import 'progreso.dart';
import 'rutina.dart';
import 'dart:io';

class ApiServicio {
  // REEMPLAZA ESTO CON LA IPV4 DE TU COMPUTADORA
  static const String ipBase = 'http://192.168.1.8:8080/api';

  static Future<bool> login(String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$ipBase/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (respuesta.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', respuesta.body);
      return true;
    }
    return false;
  }

  static Future<bool> registro(String nombre, String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$ipBase/auth/registro'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombre': nombre, 'email': email, 'password': password}),
    );
    return respuesta.statusCode == 200;
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, String>> _obtenerCabeceras() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
  }

  static Future<List<Ejercicio>> obtenerEjercicios() async {
    final respuesta = await http.get(Uri.parse('$ipBase/ejercicios'), headers: await _obtenerCabeceras());
    if (respuesta.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(respuesta.bodyBytes));
      return jsonResponse.map((data) => Ejercicio.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar ejercicios');
    }
  }

  static Future<List<Progreso>> obtenerProgresos() async {
    final respuesta = await http.get(Uri.parse('$ipBase/progresos'), headers: await _obtenerCabeceras());
    if (respuesta.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(respuesta.bodyBytes));
      return jsonResponse.map((data) => Progreso.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar progreso');
    }
  }


static Future<List<Rutina>> obtenerMisRutinas() async {
    final respuesta = await http.get(
      Uri.parse('$ipBase/rutinas'),
      headers: await _obtenerCabeceras(),
    );

    if (respuesta.statusCode == 200) {
      // Usamos utf8.decode para evitar problemas con los acentos (ñ, á, é)
      List<dynamic> cuerpo = json.decode(utf8.decode(respuesta.bodyBytes));
      return cuerpo.map((dynamic item) => Rutina.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las rutinas. Código: ${respuesta.statusCode}');
    }
  }

  static Future<bool> subirVideo(File video) async {
    // Usamos MultipartRequest para enviar archivos físicos
    var request = http.MultipartRequest('POST', Uri.parse('$ipBase/videos/subir'));
    
    // Añadimos el token de seguridad
    request.headers.addAll(await _obtenerCabeceras());
    
    // Adjuntamos el archivo de video
    request.files.add(await http.MultipartFile.fromPath('file', video.path));

    final response = await request.send();
    return response.statusCode == 200;
  }

  static Future<bool> guardarProgreso(Progreso progreso) async {
    final respuesta = await http.post(
      Uri.parse('$ipBase/progresos'),
      headers: await _obtenerCabeceras(),
      body: json.encode(progreso.toJson()),
    );
    return respuesta.statusCode == 200;
  }

  static Future<Map<String, String>> obtenerDetalleRutina(int id) async {
    final respuesta = await http.get(
      Uri.parse('$ipBase/rutinas/$id'),
      headers: await _obtenerCabeceras(),
    );

    if (respuesta.statusCode == 200) {
      return json.decode(utf8.decode(respuesta.bodyBytes));
    } else {
      throw Exception('Error al cargar detalle de rutina: ${respuesta.statusCode}');
    }
  }

  static Future<bool> crearRutina(Map<String, dynamic> datosRutina) async {
    final respuesta = await http.post(
      Uri.parse('$ipBase/rutinas'),
      headers: await _obtenerCabeceras(),
      body: json.encode(datosRutina),
    );

    // 200 (OK) o 201 (Creado) significan éxito
    if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
      return true;
    } else {
      print('Error al crear rutina: ${respuesta.body}');
      return false;
    }
  }

  static Future<Rutina> obtenerRutinaPorId(int id) async {
    // ATENCIÓN: Si tu ipBase ya dice "/api/rutinas", debes cambiar la línea de abajo 
    // por Uri.parse('$ipBase/$id') para que no se duplique la palabra rutinas.
    final url = Uri.parse('$ipBase/rutinas/$id'); 
    
    print('🌐 Buscando rutina en: $url');
    final response = await http.get(url);
    print('📥 Respuesta del servidor (Código ${response.statusCode}): ${response.body}');

    if (response.statusCode == 200) {
      return Rutina.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fallo con código ${response.statusCode}');
    }
  }
}