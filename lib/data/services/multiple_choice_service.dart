import '../models/exercise/multiple_choice_exercise.dart';

class MultipleChoiceService {
  static List<MultipleChoiceExercise> getExercises() {
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

  static bool checkAnswer({
    required int selectedIndex,
    required int correctIndex,
  }) {
    return selectedIndex == correctIndex;
  }

  static List<OptionChoice> getOptionsWithIndices(List<String> options) {
    return options
        .asMap()
        .entries
        .map((entry) => OptionChoice(
      index: entry.key,
      text: entry.value,
    ))
        .toList();
  }
}