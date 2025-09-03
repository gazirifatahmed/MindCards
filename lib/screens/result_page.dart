import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int total;
  final int score;
  const ResultPage({super.key, required this.total, required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Result')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score / $total correct', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('$pct%'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
