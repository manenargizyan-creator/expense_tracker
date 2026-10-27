import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'package:expense_tracker/widgets/data_field.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool isSaving = false;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      isExpense = transaction.isExpense;
      amountController.text = transaction.amount.toString();
      noteController.text = transaction.note;
      selectedDate = transaction.date;

      selectedCategory = switch (transaction.category) {
        TransactionCategory.food => 'Սնունդ',
        TransactionCategory.transport => 'Տրանսպորտ',
        TransactionCategory.education => 'Ուսում',
        TransactionCategory.salary => 'Աշխատավարձ',
        TransactionCategory.gift => 'Նվեր',
        TransactionCategory.business => 'Բիզնես',
        TransactionCategory.other => 'Այլ',
      };
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {
    if (isSaving) return;

    final amount = double.tryParse(
      amountController.text.trim().replaceAll(',', '.'),
    );

    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Մուտքագրիր գումարը և ընտրիր կատեգորիան։'),
        ),
      );
      return;
    }

    final category = switch (selectedCategory) {
      'Սնունդ' => TransactionCategory.food,
      'Տրանսպորտ' => TransactionCategory.transport,
      'Ուսում' => TransactionCategory.education,
      'Աշխատավարձ' => TransactionCategory.salary,
      'Նվեր' => TransactionCategory.gift,
      'Բիզնես' => TransactionCategory.business,
      _ => TransactionCategory.other,
    };

    final transaction = TransactionModel(
      id:
          widget.transaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      note: noteController.text.trim(),
      amount: amount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category,
      date: selectedDate,
    );

    setState(() {
      isSaving = true;
    });

    try {
      final provider = context.read<TransactionProvider>();

      if (isEditing) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Փոփոխությունները պահպանել չհաջողվեց։'
                : 'Գործարքը պահպանել չհաջողվեց։',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 246, 241),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 246, 241),
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
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          isEditing ? 'Խմբագրել գործարքը' : 'Նոր գործարք',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  _typeButton('Ծախս', true),
                  _typeButton('Մուտք', false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'ԳՈՒՄԱՐ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: UnderlineInputBorder(),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          ' ֏',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'ԿԱՏԵԳՈՐԻԱ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _categoryItem(
                  isExpense ? 'Սնունդ' : 'Աշխատավարձ',
                  isExpense
                      ? _expenseIcon('assets/icons/shop_bag.svg', 'Սնունդ')
                      : _incomeIcon(Icons.payments, 'Աշխատավարձ'),
                ),

                const SizedBox(width: 8),

                _categoryItem(
                  isExpense ? 'Տրանսպորտ' : 'Նվեր',
                  isExpense
                      ? _expenseIcon('assets/icons/bus.svg', 'Տրանսպորտ')
                      : _incomeIcon(Icons.card_giftcard, 'Նվեր'),
                ),

                const SizedBox(width: 8),

                _categoryItem(
                  isExpense ? 'Ուսում' : 'Բիզնես',
                  isExpense
                      ? _expenseIcon('assets/icons/comp.svg', 'Ուսում')
                      : _incomeIcon(Icons.business, 'Բիզնես'),
                ),

                const SizedBox(width: 8),

                _categoryItem(
                  'Այլ',
                  Icon(
                    Icons.add,
                    color: selectedCategory == 'Այլ'
                        ? Colors.white
                        : Colors.grey,
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              'ՆՇՈՒՄ',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Գրիր նշում...',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 15),

            DateField(
              initialDate: selectedDate,
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6D2F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Պահպանել փոփոխությունները' : 'Պահպանել',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseIcon(String asset, String title) {
    return SvgPicture.asset(
      asset,
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(
        selectedCategory == title ? Colors.white : Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _incomeIcon(IconData icon, String title) {
    return Icon(
      icon,
      color: selectedCategory == title ? Colors.white : Colors.grey,
      size: 32,
    );
  }

  Widget _typeButton(String title, bool expense) {
    final selected = isExpense == expense;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isExpense != expense) {
              isExpense = expense;
              selectedCategory = '';
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(String title, Widget icon) {
    final selected = selectedCategory == title;

    return Expanded(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                selectedCategory = title;
              });
            },
            child: Container(
              height: 60,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(child: icon),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: selected ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
