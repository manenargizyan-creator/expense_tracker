import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../data/transaction_data.dart';
import 'package:expense_tracker/widgets/data_field.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String selectedCategory = '';

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {
    final amount = double.tryParse(
      amountController.text.trim().replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0 || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Մուտքագրիր գումարը և ընտրիր կատեգորիան։'),
        ),
      );
      return;
    }

    final category = selectedCategory == 'Սնունդ'
        ? TransactionCategory.food
        : selectedCategory == 'Տրանսպորտ'
        ? TransactionCategory.transport
        : selectedCategory == 'Ուսում'
        ? TransactionCategory.education
        : TransactionCategory.other;

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      note: noteController.text.trim(),
      amount: amount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category,
      date: DateTime.now(),
    );

    try {
      final transactions = await TransactionData.loadTransactions();
      transactions.add(transaction);
      await TransactionData.saveTransactions(transactions);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Գործարքը պահպանել չհաջողվեց։')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 246, 241),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 246, 241),
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
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Նոր գործարք',
          style: TextStyle(
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
                  isExpense ? Icons.local_mall_outlined : Icons.payments,
                ),
                const SizedBox(width: 8),
                _categoryItem(
                  isExpense ? 'Տրանսպորտ' : 'Նվեր',
                  isExpense ? Icons.directions_bus : Icons.card_giftcard,
                ),
                const SizedBox(width: 8),
                _categoryItem(
                  isExpense ? 'Ուսում' : 'Բիզնես',
                  isExpense ? Icons.school_outlined : Icons.business,
                ),
                const SizedBox(width: 8),
                _categoryItem('Այլ', Icons.more_horiz),
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
            const DateField(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6D2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Պահպանել',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String title, bool expense) {
    final selected = isExpense == expense;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            isExpense = expense;
            selectedCategory = '';
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(String title, IconData icon) {
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
              decoration: BoxDecoration(
                color: selected ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: selected ? Colors.white : Colors.grey,
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
