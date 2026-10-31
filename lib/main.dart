import 'package:flutter/material.dart';
import 'pantalla_entrenamiento_activo.dart'; 
import 'pantalla_dashboard.dart'; // Importamos tu nuevo Dashboard

void main() {
  runApp(const KinetixApp());
}

class KinetixApp extends StatelessWidget {
  const KinetixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinetix Fitness',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F121D), 
        primaryColor: const Color(0xFF10B981), 
        cardColor: const Color(0xFF1E2433), 
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F121D),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF8B93A6),
        ),
        fontFamily: 'Roboto', 
      ),
      home: const PantallaPrincipalBase(),
    );
  }
}

class PantallaPrincipalBase extends StatefulWidget {
  const PantallaPrincipalBase({super.key});

  @override
  State<PantallaPrincipalBase> createState() => _PantallaPrincipalBaseState();
}

class _PantallaPrincipalBaseState extends State<PantallaPrincipalBase> {
  // Inicializamos en 0 para que la app abra directo en el Dashboard de Rutinas
  int _indiceActual = 0; 

final List<Widget> _pantallas = [
    const PantallaDashboard(),                                     
    const Center(child: Text('Abre una rutina desde el Dashboard')), // Línea corregida
    const Center(child: Text('Análisis (En construcción)')),       
    const Center(child: Text('Comunidad (En construcción)')),      
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        type: BottomNavigationBarType.fixed, 
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), 
            label: 'Rutinas'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill), 
            label: 'Entreno'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights), 
            label: 'Análisis'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), 
            label: 'Comunidad'
          ),
        ],
      ),
    );
  }
}