import 'package:flutter/material.dart';

class MonthSelectorHeader extends StatefulWidget {
  const MonthSelectorHeader({super.key});

  @override
  State<MonthSelectorHeader> createState() => _MonthSelectorHeaderState();
}

class _MonthSelectorHeaderState extends State<MonthSelectorHeader> {
  String selectedMonth = 'ՀՈԿՏԵՄԲԵՐ';

  final List<String> months = [
    'ՀՈՒՆՎԱՐ',
    'ՓԵՏՐՎԱՐ',
    'ՄԱՐՏ',
    'ԱՊՐԻԼ',
    'ՄԱՅԻՍ',
    'ՀՈՒՆԻՍ',
    'ՀՈՒԼԻՍ',
    'ՕԳՈՍՏՈՍ',
    'ՍԵՊՏԵՄԲԵՐ',
    'ՀՈԿՏԵՄԲԵՐ',
    'ՆՈՅԵՄԲԵՐ',
    'ԴԵԿՏԵՄԲԵՐ',
  ];

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: 350,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Ընտրեք ամիսը',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final isSelected = month == selectedMonth;

                    return ListTile(
                      title: Text(
                        month,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF1B4D3E)
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF1B4D3E))
                          : null,
                      onTap: () {
                        setState(() {
                          selectedMonth = month;
                        });

                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMonthPicker,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedMonth,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
