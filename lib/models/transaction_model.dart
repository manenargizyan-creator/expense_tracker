enum TransactionType { expense, income }

enum TransactionCategory {
  food,
  transport,
  education,
  other,
  salary,
  gift,
  business,
  entertainment,
}

class TransactionModel {
  final String id;
  final String note;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isExpense => type == TransactionType.expense;

  bool get isIncome => type == TransactionType.income;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      note: json['note'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      category: TransactionCategory.values.byName(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
