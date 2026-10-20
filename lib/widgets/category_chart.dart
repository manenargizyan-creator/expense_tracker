import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final double food;
  final double transport;
  final double study;
  final double other;

  const CategoryChart({
    super.key,
    required this.food,
    required this.transport,
    required this.study,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    final total = food + transport + study + other;

    if (total <= 0) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Ծախսեր դեռ չկան')),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 55,
          sectionsSpace: 3,
          sections: [
            if (food > 0) _section(food, total, Colors.orange),
            if (transport > 0) _section(transport, total, Colors.blue),
            if (study > 0) _section(study, total, Colors.purple),
            if (other > 0) _section(other, total, Colors.green),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(double amount, double total, Color color) {
    return PieChartSectionData(
      value: amount,
      color: color,
      radius: 45,
      title: '${(amount / total * 100).round()}%',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
