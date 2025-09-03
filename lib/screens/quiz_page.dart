import 'package:flutter/material.dart';
import '../models/question.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _index = 0;
  int _score = 0;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_index + 1} / ${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.stem, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...List.generate(q.options.length, (i) {
              final option = q.options[i];
              final isChosen = _selected == i;
              Color? bg;
              if (_selected != null) {
                if (i == q.correctIndex) bg = Colors.green.withOpacity(0.2);
                if (isChosen && i != q.correctIndex) bg = Colors.red.withOpacity(0.2);
              }
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  tileColor: bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(option),
                  onTap: _selected == null
                      ? () {
                          setState(() {
                            _selected = i;
                            if (i == q.correctIndex) _score++;
                          });
                        }
                      : null,
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_selected != null && q.explanation != null)
                  Expanded(
                    child: Text('💡 ${q.explanation!}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _selected == null
                      ? null
                      : () {
                          if (_index + 1 < widget.questions.length) {
                            setState(() {
                              _index++;
                              _selected = null;
                            });
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => ResultPage(
                                  total: widget.questions.length,
                                  score: _score,
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(_index + 1 < widget.questions.length ? Icons.navigate_next : Icons.flag),
                  label: Text(_index + 1 < widget.questions.length ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
