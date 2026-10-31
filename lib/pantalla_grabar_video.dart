import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'api_servicio.dart';
import 'pantalla_grabar_video.dart';

class PantallaGrabarVideo extends StatefulWidget {
  const PantallaGrabarVideo({super.key});

  @override
  State<PantallaGrabarVideo> createState() => _PantallaGrabarVideoState();
}

class _PantallaGrabarVideoState extends State<PantallaGrabarVideo> {
  CameraController? _controlador;
  List<CameraDescription>? _camaras;
  bool _grabando = false;
  int _indiceCamaraActual = 0;
  File? _videoGuardado;

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    _camaras = await availableCameras();
    if (_camaras != null && _camaras!.isNotEmpty) {
      // Busca la cámara frontal por defecto para auto-grabación
      _indiceCamaraActual = _camaras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (_indiceCamaraActual == -1) _indiceCamaraActual = 0; 
      
      await _configurarControlador(_camaras![_indiceCamaraActual]);
    }
  }

  Future<void> _configurarControlador(CameraDescription camara) async {
    final controladorAnterior = _controlador;
    _controlador = CameraController(
      camara,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controladorAnterior?.dispose();

    try {
      await _controlador!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error al inicializar cámara: $e');
    }
  }

  void _cambiarCamara() async {
    if (_camaras == null || _camaras!.length < 2 || _grabando) return;
    _indiceCamaraActual = (_indiceCamaraActual + 1) % _camaras!.length;
    await _configurarControlador(_camaras![_indiceCamaraActual]);
  }

  void _iniciarGrabacion() async {
    if (_controlador == null || !_controlador!.value.isInitialized || _grabando) return;
    try {
      await _controlador!.startVideoRecording();
      setState(() => _grabando = true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _detenerGrabacion() async {
    if (_controlador == null || !_controlador!.value.isRecordingVideo) return;
    try {
      final XFile archivoVideo = await _controlador!.stopVideoRecording();
      setState(() {
        _grabando = false;
        _videoGuardado = File(archivoVideo.path);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _descartarVideo() {
    setState(() {
      _videoGuardado = null;
    });
  }

  @override
  void dispose() {
    _controlador?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoGuardado != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisar Video')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Video capturado con éxito', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_videoGuardado == null) return;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subiendo video al servidor...')),
                      );

                      final exito = await ApiServicio.subirVideo(_videoGuardado!);

                      if (!context.mounted) return;

                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Video enviado exitosamente')),
                        );
                        Navigator.pop(context); // Cierra la cámara y vuelve al menú
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al enviar el video')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Enviar a revisión'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preparando envío...')),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Enviar a revisión'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    if (_controlador == null || !_controlador!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CameraPreview(_controlador!),
          ),
          Positioned(
            bottom: 40,
            child: GestureDetector(
              onTap: _grabando ? _detenerGrabacion : _iniciarGrabacion,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _grabando ? Colors.red : Colors.transparent,
                ),
                child: _grabando
                    ? const Icon(Icons.stop, color: Colors.white, size: 40)
                    : const Icon(Icons.circle, color: Colors.redAccent, size: 60),
              ),
            ),
          ),
          if (!_grabando)
            Positioned(
              bottom: 50,
              right: 40,
              child: IconButton(
                icon: const Icon(Icons.flip_camera_android, color: Colors.white, size: 36),
                onPressed: _cambiarCamara,
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}