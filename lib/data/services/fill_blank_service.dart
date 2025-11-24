import '../models/exercise/fill_blank_exercise.dart';

class FillBlankService {
  static List<FillBlankExercise> getExercises() {
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

  static bool checkAnswer({
    required String userAnswer,
    required FillBlankExercise exercise,
  }) {
    return exercise.isCorrect(userAnswer);
  }
}