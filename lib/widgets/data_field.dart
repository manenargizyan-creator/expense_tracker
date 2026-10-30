import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateField extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateField({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late DateTime selectedDate;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    controller = TextEditingController(
      text: DateFormat('dd MMM yyyy').format(selectedDate),
    );
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (!mounted || date == null) return;

    setState(() {
      selectedDate = date;
      controller.text = DateFormat('dd MMM yyyy', 'hy').format(date);
    });

    widget.onDateChanged(date);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: selectDate,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_month),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDCE4DC), width: 2),
        ),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
