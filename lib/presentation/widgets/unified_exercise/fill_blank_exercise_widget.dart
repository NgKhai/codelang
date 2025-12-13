import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_styles.dart';
import 'exercise_hint_card.dart';
import 'exercise_prompt_card.dart';
import 'exercise_sentence_card.dart';

class FillBlankExerciseWidget extends StatelessWidget {
  final UnifiedExerciseState state;
  final UnifiedExercise exercise;
  final TextEditingController textController;
  final FocusNode textFocusNode;
  final bool isPlayingAudio;
  final VoidCallback onPlayAudio;

  const FillBlankExerciseWidget({
    super.key,
    required this.state,
    required this.exercise,
    required this.textController,
    required this.textFocusNode,
    required this.isPlayingAudio,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final fbEx = exercise.fillBlankExercise!;

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
              prompt: fbEx.prompt,
              definition: fbEx.definition,
            ),
            const SizedBox(height: 24),
            ExerciseSentenceCardWithAudio(
              displaySentence: fbEx.getSentenceWithBlank(),
              audioSentence: fbEx.getCompleteSentence(),
              isPlayingAudio: isPlayingAudio,
              onPlayAudio: onPlayAudio,
            ),
            const SizedBox(height: 32),
            _buildFillBlankInput(context, state),
            if (fbEx.hint != null) ...[
              const SizedBox(height: 16),
              ExerciseHintCard(hint: fbEx.hint!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlankInput(
      BuildContext context,
      UnifiedExerciseState state,
      ) {
    final isAnswered =
        state.status == UnifiedExerciseStatus.correct ||
            state.status == UnifiedExerciseStatus.incorrect;

    Color? borderColor;
    if (state.status == UnifiedExerciseStatus.correct) {
      borderColor = AppColors.success;
    } else if (state.status == UnifiedExerciseStatus.incorrect) {
      borderColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.keyboard_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Your answer',
              style: AppStyles.subtitle.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: textController,
            focusNode: textFocusNode,
            enabled: !isAnswered,
            onChanged: (value) =>
                context.read<UnifiedExerciseBloc>().add(UpdateAnswer(value)),
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.primary,
                  width: 2,
                ),
              ),
              suffixIcon: isAnswered
                  ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  state.status == UnifiedExerciseStatus.correct
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: state.status == UnifiedExerciseStatus.correct
                      ? AppColors.success
                      : AppColors.error,
                  size: 28,
                ),
              )
                  : null,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!isAnswered) {
                context.read<UnifiedExerciseBloc>().add(CheckAnswer());
              }
            },
          ),
        ),
      ],
    );
  }
}
