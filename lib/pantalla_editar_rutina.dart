import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'rutina.dart';

class PantallaEditarRutina extends StatefulWidget {
  final Rutina rutinaOriginal;
  const PantallaEditarRutina({super.key, required this.rutinaOriginal});

  @override
  State<PantallaEditarRutina> createState() => _PantallaEditarRutinaState();
}

class _PantallaEditarRutinaState extends State<PantallaEditarRutina> {
  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Cargamos los ejercicios existentes al iniciar
  List _ejerciciosTemp = [];

  final TextEditingController _ejNombreController = TextEditingController();
  final TextEditingController _ejSeriesController = TextEditingController();
  final TextEditingController _ejRepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 1. Precargamos los textos con los datos de la rutina que recibimos
    _nombreController.text = widget.rutinaOriginal.nombre;
    _descripcionController.text = widget.rutinaOriginal.descripcion ?? '';
    
    // 2. Clonamos la lista de ejercicios para no afectar la original hasta guardar
    if (widget.rutinaOriginal.ejercicios != null) {
      _ejerciciosTemp = List.from(widget.rutinaOriginal.ejercicios!);
    }
  }

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 20,
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
                  labelText: 'Nombre del ejercicio',
                  labelStyle: TextStyle(color: textMuted), filled: true, fillColor: bgDark,
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
                        labelText: 'Series', labelStyle: TextStyle(color: textMuted), filled: true, fillColor: bgDark,
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
                        labelText: 'Reps', labelStyle: TextStyle(color: textMuted), filled: true, fillColor: bgDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
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

  void _actualizarRutinaEnServidor() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ponle un nombre a la rutina'), backgroundColor: Colors.redAccent));
      return;
    }
    if (_ejerciciosTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un ejercicio'), backgroundColor: Colors.redAccent));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Guardando cambios...'), backgroundColor: cardDark));

    // Estructura actualizada
    final Map<String, dynamic> rutinaActualizada = {
      'id': widget.rutinaOriginal.id, // Mantenemos el mismo ID
      'nombre': _nombreController.text,
      'descripcion': _descripcionController.text.isEmpty ? 'Rutina personalizada' : _descripcionController.text,
      'usuarioId': 1,
      'activa': true,
      'ejercicios': _ejerciciosTemp,
    };

    // Llamaremos al método PUT de ApiServicio
    bool exito = await ApiServicio.editarRutina(widget.rutinaOriginal.id!, rutinaActualizada);

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('¡Rutina actualizada!'), backgroundColor: greenAccent));
      Navigator.pop(context); 
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
        title: const Text('Editar Rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: greenAccent, size: 28),
            onPressed: _actualizarRutinaEnServidor,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Nombre de la rutina',
                labelStyle: TextStyle(color: textMuted), filled: true, fillColor: cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              style: const TextStyle(color: Colors.white), maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descripción o notas',
                labelStyle: TextStyle(color: textMuted), filled: true, fillColor: cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                TextButton.icon(
                  onPressed: _mostrarModalAgregarEjercicio,
                  icon: Icon(Icons.add, color: greenAccent, size: 18),
                  label: Text('Añadir', style: TextStyle(color: greenAccent, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),

            _ejerciciosTemp.isEmpty
                ? Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text('Sin ejercicios', style: TextStyle(color: textMuted))),
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
                                Text('${ej['series']} series × ${ej['reps']} reps', style: TextStyle(color: textMuted, fontSize: 12)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => setState(() => _ejerciciosTemp.removeAt(index)),
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