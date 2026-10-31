import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'main.dart'; // Para navegar a la aplicación principal
import 'pantalla_registro.dart';

// import 'pantalla_registro.dart'; // Lo usaremos en el próximo paso

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  void _iniciarSesion() async {
    setState(() => _cargando = true);
    
    final exito = await ApiServicio.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _cargando = false);

    if (exito) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavegacionPrincipal()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text('Fitness App', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _cargando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}