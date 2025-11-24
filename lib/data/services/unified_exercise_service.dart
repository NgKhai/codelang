import 'dart:math';
import '../models/exercise/exercise.dart';
import '../models/exercise/unified_exercise.dart';
import '../models/exercise/reorder_exercise.dart';
import '../models/exercise/multiple_choice_exercise.dart';
import '../models/exercise/fill_blank_exercise.dart';

class UnifiedExerciseService {
  // Get all exercise sets for the home screen
  static List<Exercise> getAllExerciseSets() {
    return [
      Exercise(
        id: 'beginner_translation',
        name: 'Beginner Translation',
        exercises: _getBeginnerTranslationExercises(),
      ),
      Exercise(
        id: 'vocabulary_basics',
        name: 'Vocabulary Basics',
        exercises: _getVocabularyBasicsExercises(),
      ),
      Exercise(
        id: 'grammar_fundamentals',
        name: 'Grammar Fundamentals',
        exercises: _getGrammarFundamentalsExercises(),
      ),
      Exercise(
        id: 'mixed_practice',
        name: 'Mixed Practice Set',
        exercises: _getMixedPracticeExercises(),
      ),
      Exercise(
        id: 'advanced_vocabulary',
        name: 'Advanced Vocabulary',
        exercises: _getAdvancedVocabularyExercises(),
      ),
    ];
  }

  // Get exercises for a specific exercise set
  static List<UnifiedExercise> getExercisesBySetId(String setId) {
    final exerciseSets = getAllExerciseSets();
    final set = exerciseSets.firstWhere(
          (set) => set.id == setId,
      orElse: () => exerciseSets.first,
    );
    return set.exercises;
  }

  // Get all available exercises from all types (for random practice)
  static List<UnifiedExercise> getAllExercises() {
    final allExercises = <UnifiedExercise>[];

    // Add Reorder exercises
    final reorderExercises = _getReorderExercises();
    for (int i = 0; i < reorderExercises.length; i++) {
      allExercises.add(UnifiedExercise.reorder(
        id: 'reorder_$i',
        exercise: reorderExercises[i],
      ));
    }

    // Add Multiple Choice exercises
    final multipleChoiceExercises = _getMultipleChoiceExercises();
    for (int i = 0; i < multipleChoiceExercises.length; i++) {
      allExercises.add(UnifiedExercise.multipleChoice(
        id: 'multiple_choice_$i',
        exercise: multipleChoiceExercises[i],
      ));
    }

    // Add Fill in the Blank exercises
    final fillBlankExercises = _getFillBlankExercises();
    for (int i = 0; i < fillBlankExercises.length; i++) {
      allExercises.add(UnifiedExercise.fillBlank(
        id: 'fill_blank_$i',
        exercise: fillBlankExercises[i],
      ));
    }

    return allExercises;
  }

  // Get random exercises
  static List<UnifiedExercise> getRandomExercises({int count = 10}) {
    final allExercises = getAllExercises();

    if (allExercises.length <= count) {
      allExercises.shuffle(Random());
      return allExercises;
    }

    allExercises.shuffle(Random());
    return allExercises.take(count).toList();
  }

  // Exercise sets for home screen
  static List<UnifiedExercise> _getBeginnerTranslationExercises() {
    final exercises = <UnifiedExercise>[];
    final reorderList = _getReorderExercises().take(3).toList();

    for (int i = 0; i < reorderList.length; i++) {
      exercises.add(UnifiedExercise.reorder(
        id: 'beginner_trans_$i',
        exercise: reorderList[i],
      ));
    }

    return exercises;
  }

  static List<UnifiedExercise> _getVocabularyBasicsExercises() {
    final exercises = <UnifiedExercise>[];
    final mcList = _getMultipleChoiceExercises()
        .where((ex) => ex.practiceType == 'vocabulary')
        .toList();
    final fbList = _getFillBlankExercises().take(2).toList();

    for (int i = 0; i < mcList.length; i++) {
      exercises.add(UnifiedExercise.multipleChoice(
        id: 'vocab_basic_mc_$i',
        exercise: mcList[i],
      ));
    }

    for (int i = 0; i < fbList.length; i++) {
      exercises.add(UnifiedExercise.fillBlank(
        id: 'vocab_basic_fb_$i',
        exercise: fbList[i],
      ));
    }

    return exercises;
  }

  static List<UnifiedExercise> _getGrammarFundamentalsExercises() {
    final exercises = <UnifiedExercise>[];
    final mcList = _getMultipleChoiceExercises()
        .where((ex) => ex.practiceType == 'grammar')
        .toList();

    for (int i = 0; i < mcList.length; i++) {
      exercises.add(UnifiedExercise.multipleChoice(
        id: 'grammar_fund_$i',
        exercise: mcList[i],
      ));
    }

    return exercises;
  }

  static List<UnifiedExercise> _getMixedPracticeExercises() {
    final exercises = <UnifiedExercise>[];

    // Mix of all types
    exercises.add(UnifiedExercise.reorder(
      id: 'mixed_reorder_0',
      exercise: _getReorderExercises()[0],
    ));

    exercises.add(UnifiedExercise.multipleChoice(
      id: 'mixed_mc_0',
      exercise: _getMultipleChoiceExercises()[0],
    ));

    exercises.add(UnifiedExercise.fillBlank(
      id: 'mixed_fb_0',
      exercise: _getFillBlankExercises()[0],
    ));

    exercises.add(UnifiedExercise.reorder(
      id: 'mixed_reorder_1',
      exercise: _getReorderExercises()[1],
    ));

    exercises.add(UnifiedExercise.multipleChoice(
      id: 'mixed_mc_1',
      exercise: _getMultipleChoiceExercises()[2],
    ));

    return exercises;
  }

  static List<UnifiedExercise> _getAdvancedVocabularyExercises() {
    final exercises = <UnifiedExercise>[];
    final fbList = _getFillBlankExercises();

    for (int i = 0; i < fbList.length; i++) {
      exercises.add(UnifiedExercise.fillBlank(
        id: 'adv_vocab_$i',
        exercise: fbList[i],
      ));
    }

    return exercises;
  }

  // Reorder exercises data
  static List<ReorderExercise> _getReorderExercises() {
    return const [
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "Hello world!",
        correctOrder: ["Xin", "chào!"],
        practiceType: 'translation',
      ),
      ReorderExercise(
        prompt: "Translate this phrase:",
        sourceSentence: "Le chien court rapidement.",
        correctOrder: ["The", "dog", "runs", "quickly", "."],
        practiceType: 'translation',
      ),
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "La fille chante une belle chanson.",
        correctOrder: ["The", "girl", "sings", "a", "beautiful", "song", "."],
        practiceType: 'translation',
      ),
      ReorderExercise(
        prompt: "Translate this phrase:",
        sourceSentence: "Les enfants jouent dans le parc.",
        correctOrder: ["The", "children", "play", "in", "the", "park", "."],
        practiceType: 'translation',
      ),
      ReorderExercise(
        prompt: "Translate this sentence:",
        sourceSentence: "Le soleil brille dans le ciel bleu.",
        correctOrder: ["The", "sun", "shines", "in", "the", "blue", "sky", "."],
        practiceType: 'translation',
      ),
    ];
  }

  // Multiple Choice exercises data
  static List<MultipleChoiceExercise> _getMultipleChoiceExercises() {
    return const [
      MultipleChoiceExercise(
        prompt: "Định nghĩa: quan chức, công chức",
        sentence: "Palace official are refusing to comment on the royal divorce.",
        blankWord: "official",
        blankPosition: 1,
        options: ["official", "correction fluid", "distribution", "partner"],
        correctOptionIndex: 0,
        definition: "quan chức, công chức",
        practiceType: "vocabulary",
      ),
      MultipleChoiceExercise(
        prompt: "Định nghĩa: phúc lợi phụ thêm (ngoài lương)",
        sentence: "Salary is commensurate with experience and qualifications and includes excellent benefits.",
        blankWord: "benefits",
        blankPosition: 10,
        options: ["salary", "benefits", "experience", "qualifications"],
        correctOptionIndex: 1,
        definition: "phúc lợi phụ thêm (ngoài lương)",
        practiceType: "vocabulary",
      ),
      MultipleChoiceExercise(
        prompt: "Complete the sentence with the correct word:",
        sentence: "The children are playing in the garden.",
        blankWord: "playing",
        blankPosition: 3,
        options: ["playing", "played", "play", "plays"],
        correctOptionIndex: 0,
        practiceType: "grammar",
      ),
      MultipleChoiceExercise(
        prompt: "Choose the correct preposition:",
        sentence: "She is interested in learning new languages.",
        blankWord: "in",
        blankPosition: 3,
        options: ["in", "on", "at", "for"],
        correctOptionIndex: 0,
        practiceType: "grammar",
      ),
      MultipleChoiceExercise(
        prompt: "Select the appropriate article:",
        sentence: "He bought a new car yesterday.",
        blankWord: "a",
        blankPosition: 2,
        options: ["a", "an", "the", "no article"],
        correctOptionIndex: 0,
        practiceType: "grammar",
      ),
    ];
  }

  // Fill in the Blank exercises data
  static List<FillBlankExercise> _getFillBlankExercises() {
    return const [
      FillBlankExercise(
        prompt: "(noun)\nĐịnh nghĩa:\nphúc lợi phụ thêm (ngoài lương)",
        sentence: "Salary is commensurate with experience and qualifications and includes excellent benefits.",
        correctAnswer: "benefits",
        blankPosition: 10,
        definition: "phúc lợi phụ thêm (ngoài lương)",
        wordType: "noun",
        hint: "Chú ý: điền từ gốc (đúng những gì nghe được), không điền theo dạng từ trong ô trống trên câu ví dụ.",
      ),
      FillBlankExercise(
        prompt: "Complete with the correct verb form:",
        sentence: "She has been working here for five years.",
        correctAnswer: "working",
        blankPosition: 3,
        wordType: "verb",
        acceptableAnswers: ["working"],
      ),
      FillBlankExercise(
        prompt: "Fill in with the appropriate adjective:",
        sentence: "The weather is beautiful today.",
        correctAnswer: "beautiful",
        blankPosition: 3,
        wordType: "adjective",
        acceptableAnswers: ["beautiful", "lovely", "nice"],
      ),
      FillBlankExercise(
        prompt: "Complete the sentence:",
        sentence: "He lives in a small apartment.",
        correctAnswer: "small",
        blankPosition: 4,
        wordType: "adjective",
      ),
      FillBlankExercise(
        prompt: "Type the missing preposition:",
        sentence: "The book is on the table.",
        correctAnswer: "on",
        blankPosition: 3,
        wordType: "preposition",
        acceptableAnswers: ["on"],
      ),
    ];
  }
}