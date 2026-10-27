import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const WeeklyChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final dates = List.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - index)),
    );

    // Հաշվում ենք յուրաքանչյուր օրվա իրական ծախսերը։
    final values = List.generate(7, (index) {
      final date = dates[index];

      return transactions
          .where(
            (transaction) =>
                transaction.isExpense &&
                transaction.date.year == date.year &&
                transaction.date.month == date.month &&
                transaction.date.day == date.day,
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    });

    final average = values.fold<double>(0, (sum, value) => sum + value) / 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Վերջին 7 օրը',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Միջ. ${average.toStringAsFixed(0)} ֏',
                style: const TextStyle(fontSize: 11, color: Color(0xFF285943)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 95,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: _maxY(values),
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index],
                        width: 21,
                        color: index == 6
                            ? const Color(0xFF2D8059)
                            : const Color(0xFFC4DECF),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index > 6) {
                          return const SizedBox.shrink();
                        }

                        const days = [
                          'Երկ',
                          'Երք',
                          'Չրք',
                          'Հնգ',
                          'Ուրբ',
                          'Շբթ',
                          'Կիր',
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[dates[index].weekday - 1],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF789083),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _maxY(List<double> values) {
    final maxExpense = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return maxExpense == 0 ? 100 : maxExpense * 1.25;
  }
}
