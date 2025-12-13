import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_styles.dart';
import '../available_word_widget.dart';
import '../drop_slot_widget.dart';
import 'exercise_prompt_card.dart';

class ReorderExerciseWidget extends StatelessWidget {
  final UnifiedExerciseState state;
  final UnifiedExercise exercise;

  const ReorderExerciseWidget({
    super.key,
    required this.state,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final reorderEx = exercise.reorderExercise!;

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
              prompt: reorderEx.prompt,
              sentence: reorderEx.sourceSentence,
            ),
            const SizedBox(height: 24),
            _buildDropZone(context, state),
            const SizedBox(height: 32),
            _buildAvailableWords(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, UnifiedExerciseState state) {
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
              child: Icon(
                Icons.dashboard_customize_rounded,
                color: AppColors.primary,
                size: 20,
              ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 100),
          width: double.infinity,
          child: state.currentSentence.isEmpty
              ? Center(
            child: Text(
              'Drag words here',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
              : Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: List.generate(
              state.currentSentence.length,
                  (index) => DropSlotWidget(
                index: index,
                word: state.currentSentence[index],
                onTap: () => context.read<UnifiedExerciseBloc>().add(
                  ReturnWordToBank(index),
                ),
                onWordDropped: (word, targetIndex) => context
                    .read<UnifiedExerciseBloc>()
                    .add(PlaceWordInSlot(word: word, targetIndex: targetIndex)),
                onInternalReorder: (sourceIndex, targetIndex) =>
                    context.read<UnifiedExerciseBloc>().add(
                      ReorderWordsInSlot(
                        sourceIndex: sourceIndex,
                        targetIndex: targetIndex,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableWords(
      BuildContext context,
      UnifiedExerciseState state,
      ) {
    if (state.availableWords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Text(
              'All words placed!',
              style: AppStyles.bodyText.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.apps_rounded, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Available words',
              style: AppStyles.subtitle.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          width: double.infinity,
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: state.availableWords
                .map(
                  (word) => AvailableWordWidget(
                word: word,
                onTap: () =>
                    context.read<UnifiedExerciseBloc>().add(TapWord(word)),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}
