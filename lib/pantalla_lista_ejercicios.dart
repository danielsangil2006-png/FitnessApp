import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'ejercicio.dart';
import 'visor_video.dart';

class PantallaListaEjercicios extends StatefulWidget {
  const PantallaListaEjercicios({super.key});

  @override
  State<PantallaListaEjercicios> createState() => _PantallaListaEjerciciosState();
}

class _PantallaListaEjerciciosState extends State<PantallaListaEjercicios> {
  late Future<List<Ejercicio>> _futureEjercicios;

  @override
  void initState() {
    super.initState();
    _futureEjercicios = ApiServicio.obtenerEjercicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Ejercicios')),
      body: FutureBuilder<List<Ejercicio>>(
        future: _futureEjercicios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ejercicios disponibles'));
          }

          final ejercicios = snapshot.data!;
          return ListView.builder(
            itemCount: ejercicios.length,
            itemBuilder: (context, index) {
              final ejercicio = ejercicios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // Aquí va la animación (GIF) del ejercicio si existe
                    if (ejercicio.urlAnimacion != null && ejercicio.urlAnimacion!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          ejercicio.urlAnimacion!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Si el enlace está roto o la imagen no carga, muestra un ícono gris
                            return const SizedBox(
                              height: 150,
                              child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    // Textos y botón para abrir el visor de video con Chewie
                    ListTile(
                      title: Text(ejercicio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(ejercicio.grupoMuscular ?? 'Sin categoría'),
                      trailing: IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.blueAccent, size: 30),
                        onPressed: () {
                          if (ejercicio.urlVideoTecnica != null && ejercicio.urlVideoTecnica!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisorVideo(urlVideo: ejercicio.urlVideoTecnica!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Video no disponible')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}