import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'rutina.dart';
import 'pantalla_crear_rutina.dart';
import 'pantalla_grabar_video.dart';
import 'pantalla_entrenamiento_activo.dart';

class PantallaEntrenamiento extends StatefulWidget {
  const PantallaEntrenamiento({super.key});

  @override
  State<PantallaEntrenamiento> createState() => _PantallaEntrenamientoState();
}

class _PantallaEntrenamientoState extends State<PantallaEntrenamiento> {
  late Future<List<Rutina>> _futureRutinas;

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }

  void _cargarRutinas() {
    setState(() {
      _futureRutinas = ApiServicio.obtenerRutinas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCrearRutina()));
                  if (resultado == true) _cargarRutinas();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Rutina'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Libre'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaGrabarVideo())),
                icon: const Icon(Icons.videocam),
                label: const Text('Revisión'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
              ),
            ],
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Mis Rutinas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<Rutina>>(
            future: _futureRutinas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No tienes rutinas.'));

              final rutinas = snapshot.data!;
              return ListView.builder(
                itemCount: rutinas.length,
                itemBuilder: (context, index) {
                  final rutina = rutinas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(rutina.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(rutina.descripcion),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PantallaEntrenamientoActivo(rutinaId: rutina.id!)),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}