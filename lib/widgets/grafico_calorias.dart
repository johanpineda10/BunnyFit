import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoCalorias extends StatelessWidget {
  final Map<String, double> caloriasPorComida;

  const GraficoCalorias({super.key, required this.caloriasPorComida});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    caloriasPorComida.forEach((comida, calorias) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: calorias.toDouble(),
              color: Colors.amber,
              width: 20,
            ),
          ],
        ),
      );
      index++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    caloriasPorComida.keys.elementAt(value.toInt()),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
