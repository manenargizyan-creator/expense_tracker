import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../data/transaction_data.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  bool _isLoading = true;
  String? _error;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get selectedMonth => _selectedMonth;

  int get selectedYear => _selectedYear;

  double get totalIncome {
    return _transactions
        .where(
          (t) =>
              t.isIncome &&
              t.date.month == _selectedMonth &&
              t.date.year == _selectedYear,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where(
          (t) =>
              t.isExpense &&
              t.date.month == _selectedMonth &&
              t.date.year == _selectedYear,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  List<TransactionModel> get monthTransactions {
    final result = _transactions
        .where(
          (t) => t.date.month == _selectedMonth && t.date.year == _selectedYear,
        )
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await TransactionData.loadTransactions();

      _transactions = loaded;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = 'Չհաջողվեց բեռնել գործարքները։';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final updated = [..._transactions, transaction];

    updated.sort((a, b) => b.date.compareTo(a.date));

    await TransactionData.saveTransactions(updated);

    _transactions = updated;
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    final updated = _transactions.map((transaction) {
      return transaction.id == updatedTransaction.id
          ? updatedTransaction
          : transaction;
    }).toList();

    updated.sort((a, b) => b.date.compareTo(a.date));

    await TransactionData.saveTransactions(updated);

    _transactions = updated;
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final updated = _transactions.where((t) => t.id != id).toList();

    await TransactionData.saveTransactions(updated);

    _transactions = updated;
    notifyListeners();
  }

  void selectMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }
}
