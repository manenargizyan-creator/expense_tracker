import '../models/transaction_model.dart';

class StatisticsService {
  List<TransactionModel> getExpenses(List<TransactionModel> transactions) {
    return transactions.where((transaction) => transaction.isExpense).toList();
  }

  double calculateTotalExpenses(List<TransactionModel> transactions) {
    return getExpenses(
      transactions,
    ).fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  // Ծախսերը՝ ըստ կատեգորիաների
  Map<TransactionCategory, double> calculateCategoryTotals(
    List<TransactionModel> transactions,
  ) {
    final totals = <TransactionCategory, double>{};

    for (final transaction in getExpenses(transactions)) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0) + transaction.amount;
    }

    return totals;
  }

  Map<TransactionCategory, int> calculateCategoryCounts(
    List<TransactionModel> transactions,
  ) {
    final counts = <TransactionCategory, int>{};

    for (final transaction in getExpenses(transactions)) {
      counts[transaction.category] = (counts[transaction.category] ?? 0) + 1;
    }

    return counts;
  }

  Map<TransactionCategory, double> calculateCategoryPercentages(
    List<TransactionModel> transactions,
  ) {
    final totals = calculateCategoryTotals(transactions);
    final total = calculateTotalExpenses(transactions);

    if (total == 0) {
      return {};
    }

    return totals.map((category, amount) {
      return MapEntry(category, amount / total * 100);
    });
  }

  List<TransactionModel> getLastSevenDaysExpenses(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(const Duration(days: 6));

    return getExpenses(transactions).where((transaction) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      return !date.isBefore(firstDay) && !date.isAfter(today);
    }).toList();
  }

  Map<DateTime, double> calculateDailyExpenses(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime, double>{};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      result[date] = 0;
    }

    for (final transaction in getLastSevenDaysExpenses(transactions)) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      result[date] = (result[date] ?? 0) + transaction.amount;
    }

    return result;
  }

  double calculateDailyAverage(List<TransactionModel> transactions) {
    final dailyExpenses = calculateDailyExpenses(transactions);

    final total = dailyExpenses.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    return total / 7;
  }

  TransactionCategory? getTopSpendingCategory(
    List<TransactionModel> transactions,
  ) {
    final totals = calculateCategoryTotals(transactions);

    if (totals.isEmpty) {
      return null;
    }

    return totals.entries.reduce((a, b) {
      return a.value >= b.value ? a : b;
    }).key;
  }
}
