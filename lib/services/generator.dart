import 'dart:math';
import '../models/question.dart';

enum GenerationMode { flashcards, cloze }

class FlashPair {
  final String term;
  final String definition;
  FlashPair(this.term, this.definition);
}

class Generator {
  static final _rand = Random();

  // Parse 'TERM : DEFINITION' / 'TERM - DEFINITION'
  static List<FlashPair> parsePairs(String raw) {
    final lines = raw.split(RegExp(r'\r?\n')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    final List<FlashPair> pairs = [];
    for (final line in lines) {
      final match = RegExp(r'^(.+?)\s*[:=\-–—]\s*(.+)$').firstMatch(line);
      if (match != null) {
        final term = match.group(1)!.trim();
        final def = match.group(2)!.trim();
        if (term.length >= 2 && def.length >= 4) {
          pairs.add(FlashPair(term, def));
        }
      }
    }
    return pairs;
  }

  // MCQ from flashcards: stem = definition, options = correct term + 3 distractors
  static List<Question> fromFlashcards(List<FlashPair> pairs, int count) {
    if (pairs.length < 4) {
      throw StateError('Need at least 4 valid term:definition lines to make 4-option MCQs.');
    }
    final capped = min(count, pairs.length);
    final pool = List<FlashPair>.from(pairs)..shuffle(_rand);
    final List<Question> out = [];
    for (int i = 0; i < capped; i++) {
      final correct = pool[i];
      final distractorPool = List<FlashPair>.from(pairs)..remove(correct)..shuffle(_rand);
      final distractors = distractorPool.take(3).map((p) => p.term).toList();

      final options = <String>[correct.term, ...distractors]..shuffle(_rand);
      final correctIndex = options.indexOf(correct.term);

      out.add(Question(
        stem: 'Which term matches this description?\n\n${correct.definition}',
        options: options,
        correctIndex: correctIndex,
        explanation: '${correct.term}: ${correct.definition}',
      ));
    }
    return out;
  }

  // Simple cloze MCQs from paragraphs (heuristic)
  static List<Question> fromParagraphs(String text, int count) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.split(' ').length >= 6)
        .toList();

    if (sentences.isEmpty) {
      throw StateError('Not enough sentence-like text to create cloze questions.');
    }

    final words = RegExp(r'[A-Za-z]{5,}')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toSet()
        .toList();

    final List<Question> out = [];
    final capped = min(count, sentences.length);
    final rand = _rand;

    for (int i = 0; i < capped; i++) {
      final sentence = sentences[rand.nextInt(sentences.length)];
      final candidates = RegExp(r'[A-Za-z]{5,}').allMatches(sentence).map((m) => m.group(0)!).toList();
      if (candidates.isEmpty) {
        final fallback = RegExp(r'[A-Za-z]{4,}').allMatches(sentence).map((m) => m.group(0)!).toList();
        if (fallback.isEmpty) continue;
        candidates.addAll(fallback);
      }
      candidates.shuffle(rand);
      final answer = candidates.first;
      final stem = sentence.replaceFirst(RegExp('\\b' + RegExp.escape(answer) + '\\b'), '____');

      // Similar-length distractors
      final len = answer.length;
      final pool = words.where((w) => w.toLowerCase() != answer.toLowerCase() && (w.length - len).abs() <= 2).toList();
      if (pool.length < 3) {
        pool.clear();
        pool.addAll(words.where((w) => w.toLowerCase() != answer.toLowerCase()));
      }
      pool.shuffle(rand);
      final distractors = (pool.length >= 3) ? pool.take(3).toList() : _fallbackDistractors(answer);

      final options = <String>[answer, ...distractors]..shuffle(rand);
      final correctIndex = options.indexOf(answer);

      out.add(Question(
        stem: 'Fill in the blank:\n\n$stem',
        options: options,
        correctIndex: correctIndex,
        explanation: 'Original sentence: $sentence',
      ));
    }

    if (out.isEmpty) {
      throw StateError('Could not create cloze questions from the given text.');
    }
    return out;
  }

  static List<String> _fallbackDistractors(String answer) {
    final base = answer.toLowerCase();
    final set = <String>{};
    for (int i = 0; i < base.length; i++) {
      for (final ch in ['a','e','i','o','u']) {
        final altered = base.substring(0, i) + ch + base.substring(i + 1);
        if (altered != base) set.add(_capitalizeLike(answer, altered));
        if (set.length >= 3) break;
      }
      if (set.length >= 3) break;
    }
    while (set.length < 3) {
      set.add(_capitalizeLike(answer, base + (set.length + 1).toString()));
    }
    return set.take(3).toList();
  }

  static String _capitalizeLike(String template, String word) {
    if (template.isNotEmpty && template[0].toUpperCase() == template[0]) {
      return word[0].toUpperCase() + word.substring(1);
    }
    return word;
  }
}
