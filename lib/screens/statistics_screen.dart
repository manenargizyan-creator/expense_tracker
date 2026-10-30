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

  final List<String> months = [
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

  DateTime get comparisonMonth {
    return DateTime(displayedMonth.year, displayedMonth.month - 1);
  }

  double categoryTotalForMonth(TransactionCategory category, DateTime month) {
    return transactions
        .where(
          (transaction) =>
              transaction.isExpense &&
              transaction.category == category &&
              transaction.date.month == month.month &&
              transaction.date.year == month.year,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  int categoryCountForMonth(TransactionCategory category, DateTime month) {
    return transactions
        .where(
          (transaction) =>
              transaction.isExpense &&
              transaction.category == category &&
              transaction.date.month == month.month &&
              transaction.date.year == month.year,
        )
        .length;
  }

  double categoryTotal(TransactionCategory category) {
    return categoryTotalForMonth(category, displayedMonth);
  }

  List<TransactionCategory> get activeCategories {
    final List<TransactionCategory> activeList = [];

    for (final category in TransactionCategory.values) {
      if (categoryTotal(category) > 0) {
        activeList.add(category);
      }
    }

    return activeList;
  }

  double get monthlyTotal {
    double total = 0;

    for (final category in TransactionCategory.values) {
      total += categoryTotal(category);
    }

    return total;
  }

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

  String categoryTitle(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Սնունդ';
      case TransactionCategory.transport:
        return 'Տրանսպորտ';
      case TransactionCategory.entertainment:
        return 'Զվարճանք';
      case TransactionCategory.education:
        return 'Ուսում';
      case TransactionCategory.other:
        return 'Այլ';
      case TransactionCategory.salary:
        return 'Աշխատավարձ';
      case TransactionCategory.gift:
        return 'Նվեր';
      case TransactionCategory.business:
        return 'Բիզնես';
    }
  }

  String? categoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'assets/icons/shop_bag.svg';
      case TransactionCategory.transport:
        return 'assets/icons/bus.svg';
      case TransactionCategory.education:
        return 'assets/icons/comp.svg';
      case TransactionCategory.entertainment:
      case TransactionCategory.other:
      case TransactionCategory.salary:
      case TransactionCategory.gift:
      case TransactionCategory.business:
        return null;
    }
  }

  Color categoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return const Color(0xFF2E7D56);
      case TransactionCategory.transport:
        return const Color(0xFFE8B44A);
      case TransactionCategory.entertainment:
        return const Color(0xFF8FB6E8);
      case TransactionCategory.education:
        return const Color(0xFF7FB89A);
      case TransactionCategory.other:
        return const Color(0xFFC9A6E0);
      case TransactionCategory.business:
        return const Color(0xFF8FB6E8);
      case TransactionCategory.salary:
        return const Color(0xFF2E7D56);
      case TransactionCategory.gift:
        return const Color(0xFFC9A6E0);
    }
  }

  Widget _insightBannerCard() {
    final double foodAmount = categoryTotalForMonth(
      TransactionCategory.food,
      displayedMonth,
    );

    final double dailyAverage = foodAmount > 0 ? foodAmount / 30 : 0;

    final formattedDaily = dailyAverage
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C4332),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFC6E3D4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFFC6E3D4),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFC6E3D4),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: 'Սննդի ծախսը աճել է՝ օրական միջինը '),
                  TextSpan(
                    text: '$formattedDaily ֏։',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(TransactionCategory category, double amount) {
    final color = categoryColor(category);

    final previousAmount = categoryTotalForMonth(category, comparisonMonth);

    final double changePercent = previousAmount > 0
        ? ((amount - previousAmount) / previousAmount) * 100
        : 0;

    final bool increased = amount > previousAmount;
    final bool decreased = amount < previousAmount;
    final bool isEqual = amount == previousAmount;

    final Color changeColor = increased
        ? Colors.red
        : decreased
        ? Colors.green
        : Colors.grey;

    final String changeText = isEqual
        ? '= նույնը'
        : '${increased ? '+' : ''}${changePercent.toStringAsFixed(0)}% ${increased ? '↑' : '↓'}';

    final int txCount = categoryCountForMonth(category, displayedMonth);

    final double progress = monthlyTotal > 0
        ? (amount / monthlyTotal).clamp(0.0, 1.0)
        : 0.0;

    final double sharePercent = monthlyTotal > 0
        ? (amount / monthlyTotal) * 100
        : 0.0;

    final iconPath = categoryIcon(category);

    final formattedAmount = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: iconPath != null
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          iconPath,
                          width: 18,
                          height: 18,
                          fit: BoxFit.fill,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                      )
                    : Icon(
                        category == TransactionCategory.entertainment
                            ? Icons.movie_outlined
                            : Icons.category,
                        color: color,
                        size: 18,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            categoryTitle(category),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${sharePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$txCount գործարք',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$formattedAmount ֏',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    previousAmount == 0 && amount > 0 ? '+100% ↑' : changeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: previousAmount == 0 && amount > 0
                          ? Colors.red
                          : changeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EDE8),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCategoryList = activeCategories;

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
            fontSize: 23,
            fontFamily: 'MontserratArm',
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
                  CategoryChart(
                    food: categoryTotal(TransactionCategory.food),
                    transport: categoryTotal(TransactionCategory.transport),
                    entertainment: categoryTotal(
                      TransactionCategory.entertainment,
                    ),
                    study: categoryTotal(TransactionCategory.education),
                    other: categoryTotal(TransactionCategory.other),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Մանրամասն',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (activeCategoryList.isEmpty)
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
                    ...activeCategoryList.map(
                      (category) =>
                          _categoryItem(category, categoryTotal(category)),
                    ),
                  if (activeCategoryList.isNotEmpty) _insightBannerCard(),
                ],
              ),
            ),
    );
  }
}
