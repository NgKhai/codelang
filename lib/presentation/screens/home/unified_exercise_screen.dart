import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../data/services/tts_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';
import '../../widgets/unified_exercise/exercise_progress_indicator.dart';
import '../../widgets/unified_exercise/exercise_type_chip.dart';
import '../../widgets/unified_exercise/exercise_bottom_bar.dart';
import '../../widgets/unified_exercise/reorder_exercise_widget.dart';
import '../../widgets/unified_exercise/multiple_choice_exercise_widget.dart';
import '../../widgets/unified_exercise/fill_blank_exercise_widget.dart';

class UnifiedExerciseScreen extends StatelessWidget {
  final String? exerciseSetId;
  /// Pre-loaded exercises for offline mode (if provided, uses these instead of fetching)
  final List<UnifiedExercise>? exercises;

  const UnifiedExerciseScreen({super.key, this.exerciseSetId, this.exercises});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = UnifiedExerciseBloc();
        // If exercises are provided, use offline mode; otherwise fetch from API
        if (exercises != null && exercises!.isNotEmpty) {
          bloc.add(LoadOfflineExercises(exercises: exercises!));
        } else {
          bloc.add(LoadUnifiedExercises(count: 10, exerciseSetId: exerciseSetId));
        }
        return bloc;
      },
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
                ExerciseProgressIndicator(state: state),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ExerciseTypeChip(exercise: state.currentExercise!),
                        const SizedBox(height: 12),
                        _buildExerciseContent(context, state),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                ExerciseBottomBar(
                  state: state,
                  exerciseSetId: widget.exerciseSetId,
                ),
              ],
            );
          },
        ),
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
        return ReorderExerciseWidget(
          state: state,
          exercise: exercise,
        );
      case ExerciseType.multipleChoice:
        return MultipleChoiceExerciseWidget(
          state: state,
          exercise: exercise,
        );
      case ExerciseType.fillBlank:
        return FillBlankExerciseWidget(
          state: state,
          exercise: exercise,
          textController: _textController,
          textFocusNode: _textFocusNode,
          isPlayingAudio: _isPlayingAudio,
          onPlayAudio: () async {
            setState(() => _isPlayingAudio = true);
            final fbEx = exercise.fillBlankExercise!;
            await _ttsService.speakSentence(fbEx.getCompleteSentence());
            if (mounted) {
              setState(() => _isPlayingAudio = false);
            }
          },
        );
    }
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