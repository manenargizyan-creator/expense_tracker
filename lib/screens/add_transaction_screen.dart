import 'package:expense_tracker/widgets/data_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(AddTransactionScreen());

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 243, 246, 241),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 243, 246, 241),
          leading: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 224, 223, 223)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          title: Text(
            'Նոր գործարք',
            style: TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 216, 219, 221),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isExpense = true;
                            selectedCategory = '';
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isExpense
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ծախս',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isExpense = false;
                            selectedCategory = '';
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Մուտք',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'ԳՈՒՄԱՐ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 160,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '֏',
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
              SizedBox(height: 15),
              Text(
                'ԿԱՏԵԳՈՐԻԱ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: categoryButton(
                      title: isExpense ? 'Սնունդ' : 'Աշխատավարձ',
                      icon: isExpense
                          ? Icons.local_mall_outlined
                          : Icons.payments,
                      iconColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: categoryButton(
                      title: isExpense ? 'Տրանսպորտ' : 'Նվեր',
                      icon: isExpense
                          ? Icons.business_center_outlined
                          : Icons.card_giftcard,
                      iconColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: categoryButton(
                      title: isExpense ? 'Ուսում' : 'Բիզնես',
                      icon: isExpense
                          ? Icons.desktop_windows_outlined
                          : Icons.business,
                      iconColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: categoryButton(
                      title: 'Այլ',
                      icon: Icons.more_horiz,
                      iconColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "ՆՇՈՒՄ",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 400,
                height: 50,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              DateField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryButton({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    bool isSelected = selectedCategory == title;

    return Column(
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
              color: isSelected ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : iconColor,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
