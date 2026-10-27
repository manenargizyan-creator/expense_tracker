import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionData {
  static const String _storageKey = 'saved_transactions';

  static Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);
    final List<TransactionModel> transactions = [];

    for (final item in decoded) {
      transactions.add(
        TransactionModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }

    return transactions;
  }

  static Future<void> saveTransactions(
    List<TransactionModel> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = [];

    for (final transaction in transactions) {
      data.add(transaction.toJson());
    }

    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
