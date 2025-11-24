class MultipleChoiceExercise {
  final String prompt;
  final String sentence;
  final String blankWord; // The word that should fill the blank
  final int blankPosition; // Position of the blank in the sentence
  final List<String> options;
  final int correctOptionIndex;
  final String? imageUrl;
  final String? definition;
  final String? practiceType;

  const MultipleChoiceExercise({
    required this.prompt,
    required this.sentence,
    required this.blankWord,
    required this.blankPosition,
    required this.options,
    required this.correctOptionIndex,
    this.imageUrl,
    this.definition,
    this.practiceType,
  });

  // Get the sentence with blank replaced by "_____"
  String getSentenceWithBlank() {
    final words = sentence.split(' ');
    if (blankPosition >= 0 && blankPosition < words.length) {
      words[blankPosition] = '_____';
    }
    return words.join(' ');
  }

  // Get the full sentence with the correct answer
  String getCompleteSentence() {
    return sentence;
  }
}

class OptionChoice {
  final int index;
  final String text;

  const OptionChoice({
    required this.index,
    required this.text,
  });
}