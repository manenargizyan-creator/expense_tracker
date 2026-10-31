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
        TransactionCategory.entertainment => 'Զվարճանք',
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
      'Զվարճանք' => TransactionCategory.entertainment,
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
            fontSize: 23,
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

                  // Գումարի մուտքագրման դաշտ
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SizedBox(
                      width: 135,
                      height: 65,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: UnderlineInputBorder(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF2E7D56),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF2E7D56),
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'ԿԱՏԵԳՈՐԻԱ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E7569),
              ),
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  if (isExpense) ...[
                    _categoryItem(
                      'Սնունդ',
                      _expenseIcon('assets/icons/shop_bag.svg', 'Սնունդ'),
                    ),
                    _categoryItem(
                      'Տրանսպորտ',
                      _expenseIcon('assets/icons/bus.svg', 'Տրանսպորտ'),
                    ),
                    _categoryItem(
                      'Ուսում',
                      _expenseIcon('assets/icons/comp.svg', 'Ուսում'),
                    ),
                    _categoryItem(
                      'Զվարճանք',
                      _categoryIcon(Icons.movie_outlined, 'Զվարճանք'),
                    ),
                  ] else ...[
                    _categoryItem(
                      'Աշխատավարձ',
                      _incomeIcon(Icons.payments, 'Աշխատավարձ'),
                    ),
                    _categoryItem(
                      'Նվեր',
                      _incomeIcon(Icons.card_giftcard, 'Նվեր'),
                    ),
                    _categoryItem(
                      'Բիզնես',
                      _incomeIcon(Icons.business, 'Բիզնես'),
                    ),
                  ],

                  _categoryItem('Այլ', _categoryIcon(Icons.add, 'Այլ')),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'ՆՇՈՒՄ',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5E7569),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Գրիր նշում...',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFDCE4DC),
                    width: 2,
                  ),
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
                  backgroundColor: const Color(0xFF2E7D56),
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
                          fontSize: 16.5,
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
      width: 22,
      height: 22,
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
      size: 22,
    );
  }

  Widget _categoryIcon(IconData icon, String title) {
    return Icon(
      icon,
      color: selectedCategory == title ? Colors.white : Colors.grey,
      size: 22,
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

    return SizedBox(
      width: 65,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                selectedCategory = title;
              });
            },
            child: Container(
              height: 65,
              width: 65,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D56) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2E7D56)
                      : Colors.grey.shade300,
                ),
              ),
              child: SizedBox(
                width: 22,
                height: 22,
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
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
