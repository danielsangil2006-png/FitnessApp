import 'package:flutter/material.dart';
import 'api_servicio.dart';

class PantallaCrearRutina extends StatefulWidget {
  const PantallaCrearRutina({super.key});

  @override
  State<PantallaCrearRutina> createState() => _PantallaCrearRutinaState();
}

class _PantallaCrearRutinaState extends State<PantallaCrearRutina> {
  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, dynamic>> _ejercicios = [];

  void _anadirEjercicioFalso() {
    setState(() {
      _ejercicios.add({
        'nombre': 'Nuevo Ejercicio',
        'series': 3,
        'reps': 10,
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Plantilla',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (_nombreController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ponle un nombre a tu rutina primero')),
                );
                return;
              }

              // Armamos el paquete exacto que espera Spring Boot
              Map<String, dynamic> nuevaRutina = {
                "nombre": _nombreController.text,
                "descripcion": _descController.text.isEmpty ? "Sin descripción" : _descController.text,
                "activa": true,
                "usuarioId": 1, // ¡Este es el dato clave que MySQL estaba pidiendo!
                "ejercicios": _ejercicios
              };

              bool exito = await ApiServicio.crearRutina(nuevaRutina);
              
              if (exito && mounted) {
                Navigator.pop(context); // Cierra la pantalla y vuelve al Dashboard
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al guardar. Revisa la consola.')),
                );
              }
            },
            child: Text(
              'Guardar',
              style: TextStyle(color: greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nombreController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Nombre de la rutina',
              hintStyle: TextStyle(
                color: textMuted.withOpacity(0.5),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
          ),

          TextField(
            controller: _descController,
            style: TextStyle(
              color: textMuted,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText:
                  'Añade una descripción (ej. Énfasis en tren superior)...',
              hintStyle: TextStyle(
                color: textMuted.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'EJERCICIOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${_ejercicios.length}',
                style: TextStyle(
                  color: greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._ejercicios.asMap().entries.map((entry) {
            int idx = entry.key;
            Map<String, dynamic> ej = entry.value;

            return _construirTarjetaEjercicioCreador(idx, ej);
          }),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _anadirEjercicioFalso,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Añadir Ejercicio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: Colors.white24,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaEjercicioCreador(
    int indice,
    Map<String, dynamic> ejercicio,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3245),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.fitness_center,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        title: Text(
          ejercicio['nombre']?.toString() ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text(
                '${ejercicio['series']} Series',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${ejercicio['reps']} Reps',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.redAccent,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _ejercicios.removeAt(indice);
            });
          },
        ),
      ),
    );
  }
}