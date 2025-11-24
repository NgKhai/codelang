class ReorderExercise {
  final String prompt;
  final String sourceSentence;
  final List<String> correctOrder;
  final String practiceType;

  const ReorderExercise({
    required this.prompt,
    required this.sourceSentence,
    required this.correctOrder,
    required this.practiceType,
  });
}

class WordBlock {
  final String id;
  final String text;

  const WordBlock({
    required this.id,
    required this.text,
  });
}