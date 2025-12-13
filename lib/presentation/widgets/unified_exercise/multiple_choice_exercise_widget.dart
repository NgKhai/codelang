import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../style/app_colors.dart';
import 'exercise_prompt_card.dart';
import 'exercise_sentence_card.dart';

class MultipleChoiceExerciseWidget extends StatelessWidget {
  final UnifiedExerciseState state;
  final UnifiedExercise exercise;

  const MultipleChoiceExerciseWidget({
    super.key,
    required this.state,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final mcEx = exercise.multipleChoiceExercise!;

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            ExercisePromptCard(
              prompt: mcEx.prompt,
              definition: mcEx.definition,
            ),
            const SizedBox(height: 24),
            ExerciseSentenceCard(sentence: mcEx.getSentenceWithBlank()),
            const SizedBox(height: 32),
            _buildMultipleChoiceOptions(context, state, mcEx),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(
      BuildContext context,
      UnifiedExerciseState state,
      dynamic exercise,
      ) {
    final isAnswered =
        state.status == UnifiedExerciseStatus.correct ||
            state.status == UnifiedExerciseStatus.incorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(exercise.options.length, (index) {
        final option = exercise.options[index];
        final isSelected = state.selectedOptionIndex == index;
        final isCorrect = index == exercise.correctOptionIndex;

        Color backgroundColor = Theme.of(context).cardColor;
        Color borderColor = Theme.of(context).dividerColor;
        Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
        Color circleColor = Theme.of(context).canvasColor;
        Color circleTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;

        if (isAnswered) {
          if (isCorrect) {
            backgroundColor = AppColors.success.withOpacity(0.05);
            borderColor = AppColors.success;
            textColor = AppColors.success;
            circleColor = AppColors.success;
            circleTextColor = Colors.white;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.error.withOpacity(0.05);
            borderColor = AppColors.error;
            textColor = AppColors.error;
            circleColor = AppColors.error;
            circleTextColor = Colors.white;
          } else if (index == exercise.correctOptionIndex && isSelected == false) {
            // Show correct answer if user selected wrong
            borderColor = AppColors.success.withOpacity(0.5);
            textColor = AppColors.success;
          }
        } else if (isSelected) {
          backgroundColor = AppColors.primary.withOpacity(0.05);
          borderColor = AppColors.primary;
          textColor = AppColors.primary;
          circleColor = AppColors.primary;
          circleTextColor = Colors.white;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: isAnswered
                ? null
                : () => context.read<UnifiedExerciseBloc>().add(
              SelectOption(index),
            ),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (isAnswered && isCorrect) ? 2 : 1.5,
                ),
                boxShadow: isSelected && !isAnswered
                    ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor,
                      border: Border.all(
                        color: isSelected || (isAnswered && (isCorrect || (isSelected && !isCorrect)))
                            ? Colors.transparent
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: circleTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isAnswered && isCorrect)
                    Icon(Icons.check_circle_rounded, color: AppColors.success),
                  if (isAnswered && isSelected && !isCorrect)
                    Icon(Icons.cancel_rounded, color: AppColors.error),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
