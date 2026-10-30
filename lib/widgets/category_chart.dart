import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final double food;
  final double transport;
  final double entertainment;
  final double study;
  final double other;

  const CategoryChart({
    super.key,
    required this.food,
    required this.transport,
    required this.entertainment,
    required this.study,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    final double total = food + transport + entertainment + study + other;

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
      child: Row(
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
                        if (food > 0) _section(food, const Color(0xFF2E7D56)),
                        if (transport > 0)
                          _section(transport, const Color(0xFFE8B44A)),
                        if (entertainment > 0)
                          _section(entertainment, const Color(0xFF8FB6E8)),
                        if (study > 0) _section(study, const Color(0xFF7FB89A)),
                        if (other > 0) _section(other, const Color(0xFFC9A6E0)),
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
                        'ԸՆԴԱՄԵՆԸ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A8E82),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (food > 0)
                  _legend('Սնունդ', food, total, const Color(0xFF2E7D56)),
                if (transport > 0) ...[
                  const SizedBox(height: 16),
                  _legend(
                    'Տրանսպորտ',
                    transport,
                    total,
                    const Color(0xFFE8B44A),
                  ),
                ],
                if (entertainment > 0) ...[
                  const SizedBox(height: 16),
                  _legend(
                    'Զվարճանք',
                    entertainment,
                    total,
                    const Color(0xFF8FB6E8),
                  ),
                ],
                if (study > 0) ...[
                  const SizedBox(height: 16),
                  _legend('Ուսում', study, total, const Color(0xFF7FB89A)),
                ],
                if (other > 0) ...[
                  const SizedBox(height: 16),
                  _legend('Այլ', other, total, const Color(0xFFC9A6E0)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(double amount, Color color) {
    return PieChartSectionData(
      value: amount,
      color: color,
      radius: 35,
      showTitle: false,
    );
  }

  Widget _legend(String title, double amount, double total, Color color) {
    final double percent = (amount / total) * 100;

    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
