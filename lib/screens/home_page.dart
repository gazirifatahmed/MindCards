import 'package:flutter/material.dart';
import '../services/generator.dart';
import '../services/storage.dart';
import '../models/question.dart';
import 'quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  GenerationMode _mode = GenerationMode.flashcards;
  int _count = 10;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final savedContent = await AppStorage.loadContent();
    final savedMode = await AppStorage.loadMode();
    final savedCount = await AppStorage.loadCount();
    setState(() {
      if (savedContent != null) _contentCtrl.text = savedContent;
      if (savedMode != null) {
        _mode = savedMode == 'cloze' ? GenerationMode.cloze : GenerationMode.flashcards;
      }
      if (savedCount != null && savedCount > 0) _count = savedCount;
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final raw = _contentCtrl.text.trim();
      List<Question> qs;
      if (_mode == GenerationMode.flashcards) {
        final pairs = Generator.parsePairs(raw);
        qs = Generator.fromFlashcards(pairs, _count);
      } else {
        qs = Generator.fromParagraphs(raw, _count);
      }

      await AppStorage.saveContent(raw);
      await AppStorage.saveMode(_mode == GenerationMode.cloze ? 'cloze' : 'flashcards');
      await AppStorage.saveCount(_count);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuizPage(questions: qs)),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Maker (Offline)'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('1) Choose a generation mode'),
            const SizedBox(height: 8),
            SegmentedButton<GenerationMode>(
              segments: const [
                ButtonSegment(value: GenerationMode.flashcards, label: Text('Flashcards (Best)')),
                ButtonSegment(value: GenerationMode.cloze, label: Text('Cloze from paragraph')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('2) How many questions?'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: _count.toString(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a positive number';
                      if (n > 100) return 'Keep it ≤ 100';
                      return null;
                    },
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n > 0) _count = n;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_mode == GenerationMode.flashcards
                ? '3) Paste your flashcards (one per line):\\n   TERM : DEFINITION'
                : '3) Paste your study text (paragraphs).'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentCtrl,
              minLines: 10,
              maxLines: 20,
              decoration: const InputDecoration(
                hintText: 'Example (flashcards):\\n'
                    'Photosynthesis : Process by which plants convert light into chemical energy\\n'
                    'CPU - Central Processing Unit\\n'
                    'Osmosis : Movement of water molecules across a semi-permeable membrane\\n'
                    'Gravity : A natural phenomenon by which all things with mass are brought toward one another',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please paste some content';
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(_loading ? 'Generating…' : 'Generate Quiz'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Tips',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Flashcards mode is most accurate: write "Term : Definition" per line.'),
            const Text('• You can close and reopen the app — your last input stays saved locally.'),
            const Text('• No internet or backend is needed.'),
          ],
        ),
      ),
    );
  }
}
