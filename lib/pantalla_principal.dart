import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantalla_kronos.dart';
import 'pantalla_rutinas.dart';
import 'pantalla_progreso.dart';
import 'pantalla_login.dart';

class PantallaPrincipal extends StatefulWidget {
  final int usuarioId;

  const PantallaPrincipal({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    // Inicializamos las pantallas pasando el usuarioId correspondiente
    _pantallas = [
      PantallaKronos(usuarioId: widget.usuarioId),
      PantallaRutinas(usuarioId: widget.usuarioId),
      PantallaProgreso(usuarioId: widget.usuarioId),
    ];
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PantallaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color fondoOscuro = Color(0xFF0b0d11);
    const Color superficieOscura = Color(0xFF151922);
    const Color acentoCian = Color(0xFF00E5FF);
    const Color textoClaro = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: fondoOscuro,
      body: _pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        backgroundColor: superficieOscura,
        selectedItemColor: acentoCian,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Kronos AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}