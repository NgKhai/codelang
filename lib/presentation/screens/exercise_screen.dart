import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../business/bloc/exercise/exercise_bloc.dart';
import '../../business/bloc/exercise/exercise_event.dart';
import '../../business/bloc/exercise/exercise_state.dart';
import '../../style/app_colors.dart';
import '../../style/app_styles.dart';
import '../../style/custom_app_bar.dart';
import '../widgets/available_word_widget.dart';
import '../widgets/drop_slot_widget.dart';
import '../widgets/feedback_banner.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseBloc()..add(LoadExercises()),
      child: const _SentenceReorderView(),
    );
  }
}

class _SentenceReorderView extends StatelessWidget {
  const _SentenceReorderView();

  Future<bool> _showBackDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showBackDialog(context);
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Practice',
          subtitle: 'Sentence Reorder',
          leadingIcon: Icons.school_rounded,
          showBackButton: true,
          actions: [
            AppBarActionButton(
              icon: Icons.help_outline_rounded,
              tooltip: 'Help',
              onPressed: () {
                _showHelpDialog(context);
              },
            ),
          ],
        ),
        body: BlocBuilder<ExerciseBloc, ExerciseState>(
          builder: (context, state) {
            if (state.status == ExerciseStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
      
            if (state.status == ExerciseStatus.initial || state.currentExercise == null) {
              return const Center(
                child: Text('No exercises available'),
              );
            }
      
            return Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(context, state),
      
                // Main content area (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Exercise prompt card
                        _buildPromptCard(state),
                        const SizedBox(height: 20),
      
                        // Drop zone
                        _buildDropZone(context, state),
                        const SizedBox(height: 24),
      
                        // Available words
                        _buildAvailableWords(context, state),
                        const SizedBox(height: 80), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
      
                // Bottom action bar (fixed)
                _buildBottomBar(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ExerciseState state) {
    final progress = (state.currentIndex + 1) / state.exercises.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.currentIndex + 1} of ${state.exercises.length}',
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(ExerciseState state) {
    final exercise = state.currentExercise!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
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
                    Icons.question_mark_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.prompt,
                    style: AppStyles.subtitle.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                exercise.sourceSentence,
                style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, ExerciseState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard_customize_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Your answer',
              style: AppStyles.subtitle.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: List.generate(
              state.currentSentence.length,
                  (index) => DropSlotWidget(
                index: index,
                word: state.currentSentence[index],
                onTap: () {
                  context.read<ExerciseBloc>().add(ReturnWordToBank(index));
                },
                onWordDropped: (word, targetIndex) {
                  context.read<ExerciseBloc>().add(
                    PlaceWordInSlot(word: word, targetIndex: targetIndex),
                  );
                },
                onInternalReorder: (sourceIndex, targetIndex) {
                  context.read<ExerciseBloc>().add(
                    ReorderWordsInSlot(
                      sourceIndex: sourceIndex,
                      targetIndex: targetIndex,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableWords(BuildContext context, ExerciseState state) {
    if (state.availableWords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
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
            Icon(
              Icons.apps_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Available words',
              style: AppStyles.subtitle.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: state.availableWords
              .map(
                (word) => AvailableWordWidget(
              word: word,
              onTap: () {
                context.read<ExerciseBloc>().add(TapWord(word));
              },
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ExerciseState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FeedbackBanner(
              message: state.feedbackMessage,
              type: state.feedbackType,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Reset button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset'),
                    onPressed: () {
                      context.read<ExerciseBloc>().add(ResetExercise());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Check/Next button
                Expanded(
                  flex: 2,
                  child: state.status == ExerciseStatus.correct
                      ? ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      state.isLastExercise ? 'Finish' : 'Next',
                      style: AppStyles.buttonText,
                    ),
                    onPressed: () {
                      context.read<ExerciseBloc>().add(NextExercise());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                  )
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Check Answer',
                      style: AppStyles.buttonText,
                    ),
                    onPressed: () {
                      context.read<ExerciseBloc>().add(CheckAnswer());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('How to Use'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpItem('📱 Tap', 'Tap a word to place it in the next available slot'),
            const SizedBox(height: 12),
            _helpItem('🖱️ Drag', 'Drag and drop words to specific positions'),
            const SizedBox(height: 12),
            _helpItem('🔄 Reorder', 'Drag words within the answer to rearrange them'),
            const SizedBox(height: 12),
            _helpItem('↩️ Remove', 'Tap a word in your answer to return it'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}