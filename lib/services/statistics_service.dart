import '../models/transaction_model.dart';

class StatisticsService {
  List<TransactionModel> getExpenses(List<TransactionModel> transactions) {
    return transactions.where((transaction) => transaction.isExpense).toList();
  }

  double calculateTotalExpenses(List<TransactionModel> transactions) {
    return getExpenses(transactions).fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  List<TransactionCategory> getCategories(
    List<TransactionModel> transactions,
  ) {
    final categories = <TransactionCategory>[];

    for (final transaction in getExpenses(transactions)) {
      if (!categories.contains(transaction.category)) {
        categories.add(transaction.category);
      }
    }

    return categories;
  }

  List<double> calculateCategoryTotals(
    List<TransactionModel> transactions,
  ) {
    final categories = getCategories(transactions);
    final totals = <double>[];

    for (final category in categories) {
      double total = 0;

      for (final transaction in getExpenses(transactions)) {
        if (transaction.category == category) {
          total += transaction.amount;
        }
      }

      totals.add(total);
    }

    return totals;
  }

  List<int> calculateCategoryCounts(
    List<TransactionModel> transactions,
  ) {
    final categories = getCategories(transactions);
    final counts = <int>[];

    for (final category in categories) {
      int count = 0;

      for (final transaction in getExpenses(transactions)) {
        if (transaction.category == category) {
          count++;
        }
      }

      counts.add(count);
    }

    return counts;
  }

  List<double> calculateCategoryPercentages(
    List<TransactionModel> transactions,
  ) {
    final totals = calculateCategoryTotals(transactions);
    final total = calculateTotalExpenses(transactions);
    final percentages = <double>[];

    if (total == 0) {
      return percentages;
    }

    for (final amount in totals) {
      percentages.add(amount / total * 100);
    }

    return percentages;
  }

  List<TransactionModel> getLastSevenDaysExpenses(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(Duration(days: 6));

    return getExpenses(transactions).where((transaction) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      return !date.isBefore(firstDay) && !date.isAfter(today);
    }).toList();
  }

  List<double> calculateDailyExpenses(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dailyExpenses = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      double total = 0;

      for (final transaction in getLastSevenDaysExpenses(transactions)) {
        final transactionDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );

        if (transactionDate == date) {
          total += transaction.amount;
        }
      }

      dailyExpenses.add(total);
    }

    return dailyExpenses;
  }

  double calculateDailyAverage(List<TransactionModel> transactions) {
    final dailyExpenses = calculateDailyExpenses(transactions);
    double total = 0;

    for (final amount in dailyExpenses) {
      total += amount;
    }

    return total / 7;
  }

  TransactionCategory? getTopSpendingCategory(
    List<TransactionModel> transactions,
  ) {
    final categories = getCategories(transactions);
    final totals = calculateCategoryTotals(transactions);

    if (categories.isEmpty) {
      return null;
    }

    int topIndex = 0;

    for (int i = 1; i < totals.length; i++) {
      if (totals[i] > totals[topIndex]) {
        topIndex = i;
      }
    }

    return categories[topIndex];
  }
}