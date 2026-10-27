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
    final double total = food + transport + study + other;

    if (total <= 0) {
      return Container(
        width: double.infinity,
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Ծախսեր դեռ չկան',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 42,
                          sectionsSpace: 3,
                          sections: [
                            if (food > 0) _section(food, total, Colors.orange),
                            if (transport > 0)
                              _section(transport, total, Colors.blue),
                            if (study > 0)
                              _section(study, total, Colors.purple),
                            if (other > 0) _section(other, total, Colors.green),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            child: Text(
                              '${total.toStringAsFixed(0)} ֏',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Text(
                            'Ընդհանուր',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 5),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legend('Սնունդ', Colors.orange, food, total),
                    const SizedBox(height: 16),
                    _legend('Տրանսպորտ', Colors.blue, transport, total),
                    const SizedBox(height: 16),
                    _legend('Ուսում', Colors.purple, study, total),
                    const SizedBox(height: 16),
                    _legend('Այլ', Colors.green, other, total),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(double amount, double total, Color color) {
    return PieChartSectionData(
      value: amount,
      color: color,
      radius: 35,
      title: '${(amount / total * 100).round()}%',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }

  Widget _legend(String title, Color color, double amount, double total) {
    final double percent = total > 0 ? amount / total * 100 : 0;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
