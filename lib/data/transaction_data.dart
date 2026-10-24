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

    return decoded.map((item) {
      return TransactionModel.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  static Future<void> saveTransactions(
    List<TransactionModel> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(transactions.map((item) => item.toJson()).toList());

    await prefs.setString(_storageKey, data);
  }
}
