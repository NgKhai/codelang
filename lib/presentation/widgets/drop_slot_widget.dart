import 'package:flutter/material.dart';

import '../../data/models/exercise/reorder_exercise.dart';
import '../../style/app_colors.dart';

class DropSlotWidget extends StatelessWidget {
  final int index;
  final WordBlock? word;
  final VoidCallback onTap;
  final Function(WordBlock, int) onWordDropped;
  final Function(int, int) onInternalReorder;

  const DropSlotWidget({
    super.key,
    required this.index,
    required this.word,
    required this.onTap,
    required this.onWordDropped,
    required this.onInternalReorder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) {
        return details.data is WordBlock || details.data is int;
      },
      onAcceptWithDetails: (details) {
        if (details.data is WordBlock) {
          onWordDropped(details.data as WordBlock, index);
        } else if (details.data is int) {
          onInternalReorder(details.data as int, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final bool isHighlighted = candidateData.isNotEmpty;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minWidth: 70, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.primary.withOpacity(0.1)
                  : (word != null ? AppColors.primary.withOpacity(0.05) : AppColors.primary.withOpacity(0)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: word != null ? AppColors.primary : Colors.grey.shade300,
                width: word != null ? 2 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: word != null
                ? _DraggableSlotContent(word: word!, index: index)
                : Text(
              '__',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DraggableSlotContent extends StatelessWidget {
  final WordBlock word;
  final int index;

  const _DraggableSlotContent({
    required this.word,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            word.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Text(
        word.text,
        style: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(
        word.text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}