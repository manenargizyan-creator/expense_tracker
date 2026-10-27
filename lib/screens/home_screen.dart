import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/month_selector_header.dart';
import '../widgets/weekly_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openAddScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  Future<void> _openEditScreen(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionProvider provider,
    TransactionModel transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ջնջե՞լ գործարքը'),
        content: const Text('Վստա՞հ ես, որ ցանկանում ես ջնջել այս գործարքը։'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Չեղարկել'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Ջնջել', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.deleteTransaction(transaction.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Գործարքը ջնջվեց։')));
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Չհաջողվեց ջնջել գործարքը։')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final monthTransactions = provider.monthTransactions;
    final income = provider.totalIncome;
    final expenses = provider.totalExpenses;
    final balance = provider.balance;

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
                selectedMonth: provider.selectedMonth,
                selectedYear: provider.selectedYear,
                onMonthChanged: (month) {
                  provider.selectMonth(month, provider.selectedYear);
                },
                onYearChanged: (year) {
                  provider.selectMonth(provider.selectedMonth, year);
                },
              ),

              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${balance.toStringAsFixed(0)} ֏',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 35,
                    height: 35,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/icon1.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'Մուտք − ծախս',
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
                child: WeeklyChart(transactions: provider.transactions),
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
                        MaterialPageRoute(builder: (_) => StatisticsScreen()),
                      );
                    },
                    child: const Text(
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
                child: _buildTransactions(context, provider, monthTransactions),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddScreen(context),
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

  Widget _buildTransactions(
    BuildContext context,
    TransactionProvider provider,
    List<TransactionModel> transactions,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: provider.loadTransactions,
              child: const Text('Կրկին փորձել'),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Center(child: Text('Այս ամսվա գործարքներ դեռ չկան։'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category = transaction.category;

        final backgroundColor = transaction.isIncome
            ? const Color(0xFFE1F3D8)
            : category == TransactionCategory.food
            ? const Color(0xFFFFE5D9)
            : category == TransactionCategory.transport
            ? const Color(0xFFDCEBFF)
            : category == TransactionCategory.education
            ? const Color(0xFFEDE0FF)
            : const Color(0xFFFFF0C2);

        Widget leadingIcon;

        if (transaction.isIncome) {
          leadingIcon = Icon(
            _incomeIcon(transaction.note),
            size: 25,
            color: const Color(0xFF388E3C),
          );
        } else if (category == TransactionCategory.other) {
          leadingIcon = const Icon(
            Icons.add,
            size: 25,
            color: Color(0xFFD6A020),
          );
        } else {
          leadingIcon = SvgPicture.asset(
            category == TransactionCategory.food
                ? 'assets/icons/shop_bag.svg'
                : category == TransactionCategory.transport
                ? 'assets/icons/bus.svg'
                : 'assets/icons/comp.svg',
            width: 25,
            height: 25,
          );
        }

        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            await _confirmDelete(context, provider, transaction);

            // Գործարքը հեռացնում է Provider-ը։
            return false;
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: Card(
            child: ListTile(
              onTap: () {
                _openEditScreen(context, transaction);
              },
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: leadingIcon),
              ),
              title: Text(
                transaction.note.isEmpty
                    ? _categoryLabel(category)
                    : transaction.note,
              ),
              subtitle: Text(
                '${_categoryLabel(category)} '
                '${transaction.date.day}.'
                '${transaction.date.month}',
              ),
              trailing: Text(
                '${transaction.isIncome ? '+' : '-'}'
                '${transaction.amount.toStringAsFixed(0)} ֏',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _incomeIcon(String note) {
    final text = note.toLowerCase();

    if (text.contains('աշխատավարձ')) {
      return Icons.payments;
    }

    if (text.contains('նվեր')) {
      return Icons.card_giftcard;
    }

    if (text.contains('բիզնես')) {
      return Icons.business;
    }

    return Icons.account_balance_wallet_outlined;
  }

  String _categoryLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Սնունդ';
      case TransactionCategory.transport:
        return 'Տրանսպորտ';
      case TransactionCategory.education:
        return 'Ուսում';
      case TransactionCategory.salary:
        return 'Աշխատավարձ';
      case TransactionCategory.gift:
        return 'Նվեր';
      case TransactionCategory.business:
        return 'Բիզնես';
      case TransactionCategory.other:
        return 'Այլ';
    }
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
