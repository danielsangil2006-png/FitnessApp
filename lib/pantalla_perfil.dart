import 'package:flutter/material.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textMuted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración de cuenta local'), duration: Duration(seconds: 1)),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/200?u=daniel'),
            ),
            const SizedBox(height: 16),
            const Text('Daniel Sánchez', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: greenAccent, size: 16),
                const SizedBox(width: 4),
                Text('Maracay, Venezuela', style: TextStyle(color: textMuted, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOBRE MÍ', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Estudiante de Ing. de Sistemas y desarrollador. Emprendedor en comercio electrónico de artículos deportivos y tecnología. Entusiasta del fitness entrenando 4 días a la semana y fan del buen fútbol.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HABILIDADES E INTERESES', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _etiqueta('Ingeniería de Sistemas'),
                      _etiqueta('Desarrollo C# & PHP'),
                      _etiqueta('Unity & Godot'),
                      _etiqueta('E-commerce / Importaciones'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _tarjetaEstadistica(Icons.fitness_center, 'Entrenamiento', '4x por semana')),
                const SizedBox(width: 16),
                Expanded(child: _tarjetaEstadistica(Icons.sports_soccer, 'Deporte', 'Fútbol')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
      child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _tarjetaEstadistica(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icono, color: greenAccent, size: 28),
          const SizedBox(height: 12),
          Text(titulo, style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}