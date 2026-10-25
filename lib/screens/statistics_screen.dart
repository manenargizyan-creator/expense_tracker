import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_tracker/widgets/category_chart.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/data/transaction_data.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedMonth = 0;

  final Color bgColor = const Color.fromARGB(255, 243, 246, 241);

  List<TransactionModel> transactions = [];
  bool isLoading = true;

  final List<String> months = const [
    'Հունվար',
    'Փետրվար',
    'Մարտ',
    'Ապրիլ',
    'Մայիս',
    'Հունիս',
    'Հուլիս',
    'Օգոստոս',
    'Սեպտեմբեր',
    'Հոկտեմբեր',
    'Նոյեմբեր',
    'Դեկտեմբեր',
  ];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final data = await TransactionData.loadTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Գործարքների բեռնման սխալ՝ $e');
    }
  }

  // 0՝ ընթացիկ ամիս, 1՝ նախորդ ամիս
  DateTime get displayedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month - selectedMonth);
  }

  String get currentMonthTitle {
    return months[DateTime.now().month - 1];
  }

  String get previousMonthTitle {
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1);
    return months[previous.month - 1];
  }

  // Հաշվել ընտրված ամսվա ծախսերն ըստ կատեգորիայի
  double categoryTotal(TransactionCategory category) {
    return transactions
        .where(
          (transaction) =>
              transaction.isExpense &&
              transaction.category == category &&
              transaction.date.month == displayedMonth.month &&
              transaction.date.year == displayedMonth.year,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  // Ամսվա ընտրության կոճակ
  Widget _typeButton(String title, int index) {
    final bool isSelected = selectedMonth == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedMonth = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Կատեգորիայի անվանումը
  String categoryTitle(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Սնունդ';
      case TransactionCategory.transport:
        return 'Տրանսպորտ';
      case TransactionCategory.education:
        return 'Կրթություն';
      case TransactionCategory.other:
        return 'Այլ';
    }
  }

  // Կատեգորիայի SVG պատկերակը
  String? categoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'assets/icons/shop_bag.svg';
      case TransactionCategory.transport:
        return 'assets/icons/bus.svg';
      case TransactionCategory.education:
        return 'assets/icons/comp.svg';
      case TransactionCategory.other:
        return null;
    }
  }

  // Կատեգորիայի գույնը
  Color categoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Colors.orange;
      case TransactionCategory.transport:
        return Colors.blue;
      case TransactionCategory.education:
        return Colors.purple;
      case TransactionCategory.other:
        return Colors.green;
    }
  }

  // Ընտրված ամսվա կատեգորիաների ընդհանուր գումարները
  Map<TransactionCategory, double> get categoryTotals {
    final Map<TransactionCategory, double> totals = {};

    for (final transaction in transactions) {
      if (transaction.isExpense &&
          transaction.date.month == displayedMonth.month &&
          transaction.date.year == displayedMonth.year) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final totals = categoryTotals;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 224, 223, 223),
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Կատեգորիաներ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ընթացիկ և նախորդ ամիսների ընտրություն
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 216, 219, 221),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        _typeButton(currentMonthTitle, 0),
                        _typeButton(previousMonthTitle, 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Գրաֆիկ
                  CategoryChart(
                    food: categoryTotal(TransactionCategory.food),
                    transport: categoryTotal(TransactionCategory.transport),
                    study: categoryTotal(TransactionCategory.education),
                    other: categoryTotal(TransactionCategory.other),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Մանրամասն',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 12),

                  // Կատեգորիաների ցուցակ
                  if (totals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Այս ամսվա համար ծախսեր չկան',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  else
                    ...totals.entries.map((entry) {
                      final category = entry.key;
                      final amount = entry.value;
                      final color = categoryColor(category);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: category == TransactionCategory.other
                                  ? Icon(Icons.add, color: color, size: 25)
                                  : SvgPicture.asset(
                                      categoryIcon(category)!,
                                      width: 25,
                                      height: 25,
                                      colorFilter: ColorFilter.mode(
                                        color,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                categoryTitle(category),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Text(
                              '${amount.toStringAsFixed(0)} ֏',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
