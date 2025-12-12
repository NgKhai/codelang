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

  factory ReorderExercise.fromJson(Map<String, dynamic> json) {
    return ReorderExercise(
      prompt: json['prompt'] as String,
      sourceSentence: json['sourceSentence'] as String,
      correctOrder: List<String>.from(json['correctOrder'] as List),
      practiceType: json['practiceType'] as String? ?? '',
    );
  }
}

class WordBlock {
  final String id;
  final String text;

  const WordBlock({
    required this.id,
    required this.text,
  });
}