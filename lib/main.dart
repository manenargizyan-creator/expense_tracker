import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const FinanceApp());

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const ExpenseTrackerApp(),
  );
}
