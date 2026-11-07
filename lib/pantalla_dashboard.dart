import 'package:flutter/material.dart';
import 'api_servicio.dart';
import 'rutina.dart'; 
import 'pantalla_entrenamiento_activo.dart'; 
import 'pantalla_crear_rutina.dart';
import 'pantalla_editar_rutina.dart';

class PantallaDashboard extends StatefulWidget {
  const PantallaDashboard({super.key});

  @override
  State<PantallaDashboard> createState() => _PantallaDashboardState();
}

class _PantallaDashboardState extends State<PantallaDashboard> {
  final Color bgDark = const Color(0xFF0F121D);
  final Color cardDark = const Color(0xFF1E2433);
  final Color greenAccent = const Color(0xFF10B981);
  final Color textMuted = const Color(0xFF8B93A6);

  late Future<List<Rutina>> _futureRutinas;
  List<Rutina> _rutinas = []; 
  dynamic _ultimoProgreso; 
  int _pestanaActiva = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final peticion = ApiServicio.obtenerMisRutinas();
    setState(() {
      _futureRutinas = peticion;
    });
    
    peticion.then((lista) {
      if (mounted) setState(() => _rutinas = lista);
    });

    final progreso = await ApiServicio.obtenerUltimoProgreso();
    if (mounted) {
      setState(() {
        _ultimoProgreso = progreso;
      });
    }
  }

  void _confirmarEliminacion(int idRutina) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar Rutina?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Esta acción borrará la plantilla permanentemente. Tus entrenamientos pasados en el historial se mantendrán.', style: TextStyle(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx); 
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Eliminando...'), backgroundColor: cardDark));
              
              bool exito = await ApiServicio.eliminarRutina(idRutina);
              
              if (exito && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rutina eliminada'), backgroundColor: Colors.redAccent));
                _cargarDatos(); 
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar'), backgroundColor: Colors.orangeAccent));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text('KINETIX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        actions: const [
          Center(child: Text('Rutinas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
          )
        ],
      ),
      body: RefreshIndicator(
        color: greenAccent,
        backgroundColor: cardDark,
        onRefresh: () async => _cargarDatos(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _construirResumenSemanal(),
            const SizedBox(height: 12),
            _construirEntrenoVacio(),
            const SizedBox(height: 12),
            _construirUltimoCompletado(),
            const SizedBox(height: 20),
            _construirPestanas(),
            const SizedBox(height: 16),
            
            FutureBuilder<List<Rutina>>(
              future: _futureRutinas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tienes rutinas creadas aún.', style: TextStyle(color: textMuted)));
                }

                return Column(
                  children: snapshot.data!.map((rutina) {
                    return _construirTarjetaRutina(
                      rutina: rutina,
                      categoria: 'MI RUTINA', 
                      hace: 'Guardada',
                    );
                  }).toList(),
                );
              },
            ),

            _construirCrearPlantilla(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construirResumenSemanal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: textMuted, size: 16),
                  const SizedBox(width: 8),
                  const Text('Resumen Semanal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 14),
                    SizedBox(width: 4),
                    Text('Racha 3 sem', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metrica('Sesiones', '4', '/ 5'),
              _metrica('Volumen', '48.2', ' t'),
              _metrica('Tiempo', '4h 52m', ''),
            ],
          )
        ],
      ),
    );
  }

  Widget _metrica(String titulo, String valor, String sufijo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(valor, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(sufijo, style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _construirEntrenoVacio() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2A3245), borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.add, color: Colors.black, size: 24),
        ),
        title: const Text('Iniciar Entreno Vacío', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('Registra series sobre la marcha sin plantilla', style: TextStyle(color: textMuted, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () {}, 
      ),
    );
  }

  Widget _construirUltimoCompletado() {
    String nombreRutina = 'Rutina Desconocida';
    if (_ultimoProgreso != null) {
      int idBuscado = _ultimoProgreso['rutinaId'];
      try {
        if (_rutinas.isNotEmpty) {
          final rutinaEncontrada = _rutinas.firstWhere((r) => r.id == idBuscado);
          nombreRutina = rutinaEncontrada.nombre;
        } else {
          nombreRutina = 'Rutina #$idBuscado';
        }
      } catch (e) {
        nombreRutina = 'Rutina #$idBuscado'; 
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: _ultimoProgreso == null
        ? Center(child: Text('Aún no hay entrenamientos', style: TextStyle(color: textMuted)))
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: textMuted, size: 16),
                  const SizedBox(width: 8),
                  Text('ÚLTIMO COMPLETADO', style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              Text('Reciente', style: TextStyle(color: textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombreRutina, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text('${_ultimoProgreso['tiempoSegundos'] ~/ 60}m ${_ultimoProgreso['tiempoSegundos'] % 60}s', style: TextStyle(color: textMuted, fontSize: 13)),
                        const SizedBox(width: 16),
                        Icon(Icons.fitness_center, color: textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text('${(_ultimoProgreso['seriesDetalle'] as List).length} series', style: TextStyle(color: textMuted, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _etiquetaMusculo('Sesión Guardada'),
                        _etiquetaMusculo('Datos Reales'),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(color: const Color(0xFF0F121D), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.accessibility_new, color: greenAccent, size: 40),
                    Text('HECHO', style: TextStyle(color: greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _etiquetaMusculo(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
      child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }

  Widget _construirPestanas() {
    return Row(
      children: [
        _pestanaBoton('Mis Rutinas', 0, badge: '4'),
        const SizedBox(width: 16),
        _pestanaBoton('Guardadas', 1, badge: '2'),
        const SizedBox(width: 16),
        _pestanaBoton('Explorar', 2),
      ],
    );
  }

  Widget _pestanaBoton(String titulo, int indice, {String? badge}) {
    bool activa = _pestanaActiva == indice;
    return GestureDetector(
      onTap: () {
        setState(() {
          _pestanaActiva = indice;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: activa ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: activa ? const Color(0xFF2A3245) : Colors.transparent,
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          children: [
            Text(titulo, style: TextStyle(
              color: activa ? Colors.white : textMuted, 
              fontWeight: activa ? FontWeight.bold : FontWeight.w500
            )),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: activa ? Colors.white24 : Colors.transparent, 
                  shape: BoxShape.circle
                ),
                child: Text(badge, style: TextStyle(
                  color: activa ? Colors.white : textMuted, 
                  fontSize: 10, fontWeight: FontWeight.bold
                )),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaRutina({required Rutina rutina, required String categoria, required String hace}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(categoria, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: textMuted, size: 20),
                color: const Color(0xFF2A3245),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (valor) async {
                  if (valor == 'eliminar' && rutina.id != null) {
                    _confirmarEliminacion(rutina.id!);
                  } else if (valor == 'editar' && rutina.id != null) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaEditarRutina(rutinaOriginal: rutina)
                      ),
                    );
                    _cargarDatos();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Editar rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        SizedBox(width: 10),
                        Text('Eliminar rutina', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(rutina.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0F121D), borderRadius: BorderRadius.circular(8)),
            child: Text(rutina.descripcion ?? '', style: TextStyle(color: textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(hace, style: TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (rutina.id != null) {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaEntrenoVivo(rutinaId: rutina.id!)));
                    _cargarDatos();
                  }
                },
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.black),
                label: const Text('Iniciar rutina', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _construirCrearPlantilla() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF2A3245), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.paste, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          const Text('¿Quieres estructurar un nuevo plan?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Organiza tus series, descansos programados y notas de técnica.', style: TextStyle(color: textMuted, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCrearRutina()));
              _cargarDatos(); 
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('Crear nueva plantilla', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }
}