import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_servicio.dart';
import 'progreso.dart';

class PantallaProgreso extends StatefulWidget {
  const PantallaProgreso({super.key});

  @override
  State<PantallaProgreso> createState() => _PantallaProgresoState();
}

class _PantallaProgresoState extends State<PantallaProgreso> {
  late Future<List<Progreso>> _futureProgresos;

  @override
  void initState() {
    super.initState();
    _futureProgresos = ApiServicio.obtenerProgresos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso')),
      body: FutureBuilder<List<Progreso>>(
        future: _futureProgresos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error al cargar progreso'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Aún no hay datos de entrenamientos.'));

          final progresos = snapshot.data!;
          // Creamos puntos para la gráfica basados en el peso total levantado
          final spots = progresos.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.pesoTotalLevantado);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.3)),
                  )
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}