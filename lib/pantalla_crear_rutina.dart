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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Lista dinámica para almacenar los ejercicios que el usuario va añadiendo
  final List _ejerciciosTemp = [];

  // Controladores temporales para el formulario flotante de nuevo ejercicio
  final TextEditingController _ejNombreController = TextEditingController();
  final TextEditingController _ejSeriesController = TextEditingController();
  final TextEditingController _ejRepsController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ejNombreController.dispose();
    _ejSeriesController.dispose();
    _ejRepsController.dispose();
    super.dispose();
  }

  void _mostrarModalAgregarEjercicio() {
    _ejNombreController.clear();
    _ejSeriesController.clear();
    _ejRepsController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Añadir Ejercicio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _ejNombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre del ejercicio (ej. Press de Banca)',
                  labelStyle: TextStyle(color: textMuted),
                  filled: true,
                  fillColor: bgDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ejSeriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Series (ej. 4)',
                        labelStyle: TextStyle(color: textMuted),
                        filled: true,
                        fillColor: bgDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ejRepsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Reps (ej. 10)',
                        labelStyle: TextStyle(color: textMuted),
                        filled: true,
                        fillColor: bgDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: greenAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (_ejNombreController.text.isNotEmpty && _ejSeriesController.text.isNotEmpty && _ejRepsController.text.isNotEmpty) {
                      setState(() {
                        _ejerciciosTemp.add({
                          'nombre': _ejNombreController.text,
                          'series': int.tryParse(_ejSeriesController.text) ?? 3,
                          'reps': int.tryParse(_ejRepsController.text) ?? 10,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar a la rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _guardarRutinaEnServidor() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ponle un nombre a la rutina'), backgroundColor: Colors.redAccent));
      return;
    }

    if (_ejerciciosTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un ejercicio a la rutina'), backgroundColor: Colors.redAccent));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Guardando plantilla...'), backgroundColor: cardDark));

    // Estructura que espera Spring Boot para crear la rutina y sus ejercicios en cascada
    final Map<String, dynamic> nuevaRutina = {
      'nombre': _nombreController.text,
      'descripcion': _descripcionController.text.isEmpty ? 'Rutina personalizada' : _descripcionController.text,
      'usuarioId': 1,
      'activa': true,
      'ejercicios': _ejerciciosTemp,
    };

    bool exito = await ApiServicio.crearRutina(nuevaRutina);

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('¡Rutina creada con éxito!'), backgroundColor: greenAccent));
      Navigator.pop(context); // Regresa al Dashboard y este se refrescará automáticamente
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Text('Nueva Plantilla de Rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: greenAccent, size: 28),
            onPressed: _guardarRutinaEnServidor,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMACIÓN GENERAL
            TextField(
              controller: _nombreController,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Nombre de la rutina (ej. Día de Pierna)',
                labelStyle: TextStyle(color: textMuted),
                filled: true,
                fillColor: cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descripción o notas (opcional)',
                labelStyle: TextStyle(color: textMuted),
                filled: true,
                fillColor: cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // SECCIÓN DE EJERCICIOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                TextButton.icon(
                  onPressed: _mostrarModalAgregarEjercicio,
                  icon: Icon(Icons.add, color: greenAccent, size: 18),
                  label: Text('Añadir ejercicio', style: TextStyle(color: greenAccent, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),

            _ejerciciosTemp.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text('Aún no has agregado ejercicios', style: TextStyle(color: textMuted))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ejerciciosTemp.length,
                    itemBuilder: (context, index) {
                      final ej = _ejerciciosTemp[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${index + 1}. ${ej['nombre']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('${ej['series']} series × ${ej['reps']} repeticiones', style: TextStyle(color: textMuted, fontSize: 12)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _ejerciciosTemp.removeAt(index);
                                });
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}