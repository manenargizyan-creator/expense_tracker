import 'package:expense_tracker/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/add_transaction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/transaction_model.dart';
import '../data/transaction_data.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/month_selector_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await TransactionData.loadTransactions();

    if (!mounted) return;

    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  Future<void> _openAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    await loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final monthTransactions = transactions.where((transaction) {
      return transaction.date.year == selectedYear &&
          transaction.date.month == selectedMonth;
    }).toList();

    final income = monthTransactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final expenses = monthTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 210,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonthSelectorHeader(
                selectedMonth: selectedMonth,
                onMonthChanged: (month) {
                  setState(() {
                    selectedMonth = month;
                  });
                },
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    '$balance ֏',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 35,
                    height: 35,
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/icons/icon1.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'Մնացորդ ամսվա վերջում',
                style: TextStyle(
                  color: Colors.lightGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _balanceCard('Մուտք', income, const Color(0xFF96B870)),
                  const SizedBox(width: 12),
                  _balanceCard('Ծախս', expenses, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: WeeklyChart(
                  expenses: monthTransactions
                      .where((t) => t.isExpense)
                      .map((t) => t.amount)
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Գործարքներ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Բոլորը',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : monthTransactions.isEmpty
                    ? const Center(
                        child: Text('Այս ամսվա գործարքներ դեռ չկան։'),
                      )
                    : ListView.builder(
                        itemCount: monthTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = monthTransactions[index];

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                transaction.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: transaction.isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                transaction.note.isEmpty
                                    ? transaction.category.name
                                    : transaction.note,
                              ),
                              subtitle: Text(
                                '${transaction.date.day}.'
                                '${transaction.date.month}.'
                                '${transaction.date.year}',
                              ),
                              trailing: Text(
                                '${transaction.isIncome ? '+' : '-'}'
                                '${transaction.amount.toStringAsFixed(0)} ֏',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isIncome
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openAddScreen,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text(
                    'Նոր գործարք',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6D2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard(String title, double amount, Color titleColor) {
    return Expanded(
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: titleColor, fontSize: 14)),
            const SizedBox(height: 5),
            Text(
              '${amount.toStringAsFixed(0)} ֏',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
