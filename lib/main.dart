import 'package:flutter/material.dart';

import 'pantalla_dashboard.dart';
import 'pantalla_historial.dart';
import 'pantalla_perfil.dart';
import 'pantalla_kronos.dart';

void main() {
  runApp(const KinetixApp());
}

class KinetixApp extends StatelessWidget {
  const KinetixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinetix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF10B981),
        scaffoldBackgroundColor: const Color(0xFF0F121D),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  final Color bgDark = const Color(0xFF0F121D);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  // EXACTAMENTE 4 ELEMENTOS (Índices 0, 1, 2 y 3)
  // Las 4 pantallas (Dashboard, Kronos, Análisis y Perfil)
  final List<Widget> _pantallas = [
    const PantallaDashboard(), // Índice 0
    const PantallaKronos(usuarioId: 1,),    // Índice 1 - ¡Aquí vive nuestro chatbot!
    const PantallaHistorial(), // Índice 2
    const PantallaPerfil(),    // Índice 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: _pantallas[_indiceActual],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual > 3 ? 0 : _indiceActual, // Protección extra contra desbordes
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          backgroundColor: bgDark,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: greenAccent,
          unselectedItemColor: textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'Kronos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Análisis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}