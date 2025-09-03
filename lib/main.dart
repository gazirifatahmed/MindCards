import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MCQApp());
}

class MCQApp extends StatelessWidget {
  const MCQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}
