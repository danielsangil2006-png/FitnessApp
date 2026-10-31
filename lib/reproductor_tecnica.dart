import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ReproductorTecnica extends StatefulWidget {
  final String videoUrl;

  const ReproductorTecnica({super.key, required this.videoUrl});

  @override
  State<ReproductorTecnica> createState() => _ReproductorTecnicaState();
}

class _ReproductorTecnicaState extends State<ReproductorTecnica> {
  late VideoPlayerController _controladorVideo;
  ChewieController? _controladorChewie;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  Future<void> _inicializarReproductor() async {
    // Inicializamos el video desde un enlace de internet (simulando tu nube)
    _controladorVideo = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    
    await _controladorVideo.initialize();

    _controladorChewie = ChewieController(
      videoPlayerController: _controladorVideo,
      autoPlay: true,
      looping: true,
      aspectRatio: _controladorVideo.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
        );
      },
    );
    
    // Actualizamos la pantalla una vez que el video cargó
    setState(() {});
  }

  @override
  void dispose() {
    _controladorVideo.dispose();
    _controladorChewie?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controladorChewie != null &&
            _controladorChewie!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _controladorChewie!)
        : const Center(child: CircularProgressIndicator());
  }
}