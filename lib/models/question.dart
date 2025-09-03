class Question {
  final String stem; // The question text (or cloze sentence with ____)
  final List<String> options; // Shuffled options (length = 4)
  final int correctIndex; // Index into options
  final String? explanation; // Optional explanation/definition

  Question({
    required this.stem,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}
