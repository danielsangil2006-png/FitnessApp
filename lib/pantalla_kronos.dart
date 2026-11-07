import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiServicio {
  // Asegúrate de que este puerto (8081) coincida con el que configuraste en tu Spring Boot
  static const String baseUrl = "http://192.168.1.8:8081/api/kronos";

  static Future<List> obtenerHistorial(int usuarioId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/historial/$usuarioId'))
          .timeout(const Duration(seconds: 5)); // Evita que se quede cargando infinitamente

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => {
          'rol': item['rol'],
          'contenido': item['contenido'],
        }).toList();
      }
    } catch (e) {
      print("Error al cargar historial: $e");
    }
    return []; // Retorna lista vacía si falla para evitar el bloqueo del FutureBuilder
  }

  static Future<String?> enviarMensajeKronos(int usuarioId, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioId": usuarioId, "mensaje": mensaje}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['respuesta'];
      }
    } catch (e) {
      print("Error al enviar mensaje: $e");
    }
    return null;
  }
}

class PantallaKronos extends StatefulWidget {
  final int usuarioId;

  const PantallaKronos({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _PantallaKronosState createState() => _PantallaKronosState();
}

class _PantallaKronosState extends State<PantallaKronos> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    String texto = _controller.text.trim();
    if (texto.isEmpty || _isThinking) return;

    _controller.clear();
    setState(() => _isThinking = true);
    _scrollToBottom();

    await ApiServicio.enviarMensajeKronos(widget.usuarioId, texto);

    setState(() => _isThinking = false);
    _scrollToBottom();
    
    // Forzamos la actualización para redibujar el nuevo mensaje
    setState(() {});
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
        title: const Text("Kronos - AI Coach", style: TextStyle(color: textoClaro, fontWeight: FontWeight.bold)),
        backgroundColor: superficieOscura,
        iconTheme: const IconThemeData(color: acentoCian),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List>(
              future: ApiServicio.obtenerHistorial(widget.usuarioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: acentoCian));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error al conectar con el servidor.",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                List mensajes = List.from(snapshot.data ?? []);

                if (_isThinking) {
                  mensajes.add({
                    'rol': 'assistant_typing',
                    'contenido': 'Kronos está analizando tus datos y redactando un consejo...'
                  });
                }

                _scrollToBottom();

                if (mensajes.isEmpty && !_isThinking) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "¡Hola! Soy Kronos, tu coach de Kinetix.\nPregúntame sobre tus rutinas o sobrecarga progresiva.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = mensajes[index];
                    bool esEscribiendo = msg['rol'] == 'assistant_typing';
                    bool esUsuario = msg['rol'] == 'user';

                    if (esEscribiendo) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: superficieOscura,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: acentoCian.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: acentoCian),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                msg['contenido'],
                                style: const TextStyle(fontSize: 14, color: Colors.white60, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: esUsuario ? const Color(0xFF1E293B) : superficieOscura,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: esUsuario ? acentoCian.withOpacity(0.3) : Colors.white10,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          msg['contenido'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: esUsuario ? textoClaro : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Barra inferior de escritura
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: superficieOscura,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: textoClaro),
                    decoration: InputDecoration(
                      hintText: "Escribe tu duda a Kronos...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: fondoOscuro,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: acentoCian,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF0b0d11)),
                    onPressed: _isThinking ? null : _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}