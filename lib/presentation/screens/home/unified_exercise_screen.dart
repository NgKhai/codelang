// lib/presentation/screens/unified_exercise_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../data/services/tts_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_styles.dart';
import '../../../style/custom_app_bar.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/available_word_widget.dart';
import '../../widgets/drop_slot_widget.dart';

class UnifiedExerciseScreen extends StatelessWidget {
  final String? exerciseSetId;

  const UnifiedExerciseScreen({super.key, this.exerciseSetId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UnifiedExerciseBloc()
        ..add(LoadUnifiedExercises(count: 10, exerciseSetId: exerciseSetId)),
      child: _UnifiedExerciseView(exerciseSetId: exerciseSetId),
    );
  }
}

class _UnifiedExerciseView extends StatefulWidget {
  final String? exerciseSetId;
  
  const _UnifiedExerciseView({this.exerciseSetId});

  @override
  State<_UnifiedExerciseView> createState() => _UnifiedExerciseViewState();
}

class _UnifiedExerciseViewState extends State<_UnifiedExerciseView> {
  final TextEditingController _textController = TextEditingController();

  final FocusNode _textFocusNode = FocusNode();
  final TtsService _ttsService = TtsService();
  bool _isPlayingAudio = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _ttsService.dispose();
    super.dispose();
  }

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
    // Check if we can pop without dialog (first exercise or explicitly allowed)
    final isFirstExercise = context.select(
      (UnifiedExerciseBloc bloc) => bloc.state.currentIndex == 0,
    );
    final canPop = isFirstExercise || _allowExit;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _showBackDialog(context);
        if (shouldPop && context.mounted) {
          setState(() => _allowExit = true);
          // Post frame to allow state update to take effect before popping
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pop();
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'CodeLang',
          subtitle: 'Learning with the coding',
          leadingIcon: Icons.school_rounded,
          showBackButton: true,
          onLeadingIconPressed: () => Navigator.maybePop(context),
          actions: [
            AppBarActionButton(
              icon: Icons.help_outline_rounded,
              tooltip: 'Help',
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
        body: BlocConsumer<UnifiedExerciseBloc, UnifiedExerciseState>(
          listener: (context, state) {
            // Clear text field and manage focus for Fill in the Blank exercises
            if (state.currentExercise?.type == ExerciseType.fillBlank) {
              if (state.status == UnifiedExerciseStatus.loaded &&
                  state.userAnswer.isEmpty) {
                _textController.clear();
                // Auto-focus the text field when entering Fill in the Blank exercise
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _textFocusNode.canRequestFocus) {
                    _textFocusNode.requestFocus();
                  }
                });
              }
            } else {
              // Unfocus keyboard when not in Fill in the Blank exercise
              _textFocusNode.unfocus();
            }
          },
          builder: (context, state) {
            if (state.status == UnifiedExerciseStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.currentExercise == null) {
              return const Center(child: Text('No exercises available'));
            }

            return Column(
              children: [
                _buildProgressIndicator(context, state),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildExerciseTypeChip(state),
                        const SizedBox(height: 12),
                        _buildExerciseContent(context, state),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    UnifiedExerciseState state,
  ) {
    final progress = (state.currentIndex + 1) / state.exercises.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.currentIndex + 1} / ${state.exercises.length}',
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeChip(UnifiedExerciseState state) {
    final exercise = state.currentExercise!;
    IconData icon;
    Color color;

    switch (exercise.type) {
      case ExerciseType.reorder:
        icon = Icons.reorder;
        color = Colors.blue;
        break;
      case ExerciseType.multipleChoice:
        icon = Icons.quiz;
        color = Colors.purple;
        break;
      case ExerciseType.fillBlank:
        icon = Icons.edit_note;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            exercise.getTypeName(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(
    BuildContext context,
    UnifiedExerciseState state,
  ) {
    final exercise = state.currentExercise!;

    switch (exercise.type) {
      case ExerciseType.reorder:
        return _buildReorderExercise(context, state, exercise);
      case ExerciseType.multipleChoice:
        return _buildMultipleChoiceExercise(context, state, exercise);
      case ExerciseType.fillBlank:
        return _buildFillBlankExercise(context, state, exercise);
    }
  }

  // REORDER EXERCISE
  Widget _buildReorderExercise(
    BuildContext context,
    UnifiedExerciseState state,
    UnifiedExercise exercise,
  ) {
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
            _buildPromptCard(reorderEx.prompt, reorderEx.sourceSentence),
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

  // MULTIPLE CHOICE EXERCISE
  Widget _buildMultipleChoiceExercise(
    BuildContext context,
    UnifiedExerciseState state,
    UnifiedExercise exercise,
  ) {
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
            _buildPromptCard(mcEx.prompt, null, definition: mcEx.definition),
            const SizedBox(height: 24),
            _buildSentenceCard(mcEx.getSentenceWithBlank()),
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

  // FILL IN THE BLANK EXERCISE
  Widget _buildFillBlankExercise(
    BuildContext context,
    UnifiedExerciseState state,
    UnifiedExercise exercise,
  ) {
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
            _buildPromptCard(fbEx.prompt, null, definition: fbEx.definition),
            const SizedBox(height: 24),
            _buildSentenceCardWithAudio(
              context,
              fbEx.getSentenceWithBlank(),
              fbEx.getCompleteSentence(),
            ),
            const SizedBox(height: 32),
            _buildFillBlankInput(context, state),
            if (fbEx.hint != null) ...[
              const SizedBox(height: 16),
              _buildHintCard(fbEx.hint!),
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
            controller: _textController,
            focusNode: _textFocusNode,
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

  Widget _buildPromptCard(
    String prompt,
    String? sentence, {
    String? definition,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prompt,
                        style: AppStyles.subtitle.copyWith(
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (sentence != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Text(
                sentence,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (definition != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      definition,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentenceCard(String sentence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        sentence,
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSentenceCardWithAudio(
    BuildContext context,
    String displaySentence,
    String audioSentence,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            displaySentence,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  setState(() => _isPlayingAudio = true);
                  await _ttsService.speakSentence(audioSentence);
                  if (mounted) {
                    setState(() => _isPlayingAudio = false);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlayingAudio
                            ? Icons.volume_up_rounded
                            : Icons.volume_up_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isPlayingAudio ? 'Playing...' : 'Listen to sentence',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard(String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.orange.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.orange.shade900,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, UnifiedExerciseState state) {
    final canShowAnswer =
        state.currentExercise?.type == ExerciseType.fillBlank &&
        state.status == UnifiedExerciseStatus.incorrect;

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
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset'),
                    onPressed: () => context.read<UnifiedExerciseBloc>().add(
                      ResetCurrentExercise(),
                    ),
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
                if (canShowAnswer) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Show'),
                      onPressed: () =>
                          context.read<UnifiedExerciseBloc>().add(ShowAnswer()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: state.status == UnifiedExerciseStatus.correct
                      ? ElevatedButton.icon(
                          icon: Icon(
                            state.isLastExercise
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            state.isLastExercise ? 'Complete' : 'Next',
                            style: AppStyles.buttonText,
                          ),
                          onPressed: () {
                            if (state.isLastExercise) {
                              // Complete the streak when finishing all exercises
                              context.read<AuthBloc>().add(AuthCompleteStreakRequested());
                              
                              // Complete the course if it's a specific course (not random)
                              final courseId = widget.exerciseSetId;
                              if (courseId != null && courseId != 'random') {
                                context.read<AuthBloc>().add(
                                  AuthCompleteCourseRequested(courseId: courseId),
                                );
                              }
                              
                              context.pop(); // Go back to previous screen (Home)
                            } else {
                              context
                                  .read<UnifiedExerciseBloc>()
                                  .add(NextExercise());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.check_rounded),
                          label: const Text(
                            'Check Answer',
                            style: AppStyles.buttonText,
                          ),
                          onPressed: () => context
                              .read<UnifiedExerciseBloc>()
                              .add(CheckAnswer()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            _helpItem('🔀 Reorder', 'Drag or tap words to build sentences'),
            const SizedBox(height: 12),
            _helpItem(
              '✓ Multiple Choice',
              'Select the correct option from 4 choices',
            ),
            const SizedBox(height: 12),
            _helpItem(
              '✏️ Fill Blank',
              'Type the missing word in the text field',
            ),
            const SizedBox(height: 12),
            _helpItem('🔊 Audio', 'Tap the speaker icon to hear the sentence'),
            const SizedBox(height: 12),
            _helpItem('🎲 Random', 'Exercises are randomly mixed for variety'),
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
