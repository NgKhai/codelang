class FillBlankExercise {
  final String prompt;
  final String sentence;
  final String correctAnswer;
  final int blankPosition; // Position of the blank in the sentence
  final String? imageUrl;
  final String? definition;
  final String? wordType; // noun, verb, adjective, etc.
  final String? hint;
  final List<String>? acceptableAnswers; // Alternative correct answers

  const FillBlankExercise({
    required this.prompt,
    required this.sentence,
    required this.correctAnswer,
    required this.blankPosition,
    this.imageUrl,
    this.definition,
    this.wordType,
    this.hint,
    this.acceptableAnswers,
  });

  // Get the sentence with blank replaced by "_____"
  String getSentenceWithBlank() {
    final words = sentence.split(' ');
    if (blankPosition >= 0 && blankPosition < words.length) {
      words[blankPosition] = '_____';
    }
    return words.join(' ');
  }

  // Check if answer is correct
  bool isCorrect(String userAnswer) {
    final cleanAnswer = userAnswer.trim().toLowerCase();
    final cleanCorrect = correctAnswer.trim().toLowerCase();

    if (cleanAnswer == cleanCorrect) {
      return true;
    }

    if (acceptableAnswers != null) {
      return acceptableAnswers!
          .any((answer) => answer.trim().toLowerCase() == cleanAnswer);
    }

    return false;
  }

  // Get the complete sentence with answer
  String getCompleteSentence() {
    return sentence;
  }
}