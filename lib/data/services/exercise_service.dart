// lib/services/exercise_service.dart

import '../models/exercise/reorder_exercise.dart';

class ExerciseService {
  // Mock data - in real app, this would come from API or local database
  static List<ReorderExercise> getExercises() {
    return const [
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "Hello world!",
        correctOrder: ["Xin", "chào!"],
        practiceType: '',
      ),
      ReorderExercise(
        prompt: "Translate this phrase:",
        sourceSentence: "Le chien court rapidement.",
        correctOrder: ["The", "dog", "runs", "quickly", "."],
        practiceType: '',
      ),
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "La fille chante une belle chanson.",
        correctOrder: ["The", "girl", "sings", "a", "beautiful", "song", "."],
        practiceType: '',
      ),
      ReorderExercise(
        prompt: "Translate this phrase:",
        sourceSentence: "Les enfants jouent dans le parc.",
        correctOrder: ["The", "children", "play", "in", "the", "park", "."],
        practiceType: '',
      ),
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "Le soleil brille dans le ciel bleu.",
        correctOrder: ["The", "sun", "shines", "in", "the", "blue", "sky", "."],
        practiceType: '',
      ),
    ];
  }

  static List<WordBlock> shuffleWords(List<String> words) {
    final wordBlocks = words.asMap().entries.map((entry) {
      return WordBlock(id: entry.key.toString(), text: entry.value);
    }).toList();

    wordBlocks.shuffle();
    return wordBlocks;
  }

  static bool checkAnswer({
    required List<WordBlock?> userAnswer,
    required List<String> correctAnswer,
  }) {
    if (userAnswer.contains(null)) {
      return false;
    }

    final userWords = userAnswer.map((w) => w!.text).toList();

    if (userWords.length != correctAnswer.length) {
      return false;
    }

    for (int i = 0; i < userWords.length; i++) {
      if (userWords[i] != correctAnswer[i]) {
        return false;
      }
    }

    return true;
  }
}
