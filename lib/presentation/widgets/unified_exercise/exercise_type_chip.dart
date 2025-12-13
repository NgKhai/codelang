import 'package:flutter/material.dart';

import '../../../data/models/exercise/unified_exercise.dart';

class ExerciseTypeChip extends StatelessWidget {
  final UnifiedExercise exercise;

  const ExerciseTypeChip({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
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
}
