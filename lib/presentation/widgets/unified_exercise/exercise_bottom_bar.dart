import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_bloc.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_event.dart';
import '../../../business/bloc/unified_exercise/unified_exercise_state.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_styles.dart';
import '../feedback_banner.dart';

class ExerciseBottomBar extends StatelessWidget {
  final UnifiedExerciseState state;
  final String? exerciseSetId;

  const ExerciseBottomBar({
    super.key,
    required this.state,
    this.exerciseSetId,
  });

  @override
  Widget build(BuildContext context) {
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
                        final courseId = exerciseSetId;
                        
                        // Only complete streak when doing daily streak (random exercises)
                        if (courseId == 'random' || courseId == null) {
                          context.read<AuthBloc>().add(AuthCompleteStreakRequested());
                        }

                        // Complete the course if it's a specific course (not random)
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
}
