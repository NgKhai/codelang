import 'package:flutter/material.dart';

import '../../business/bloc/exercise/exercise_state.dart';
import '../../style/app_colors.dart';


class FeedbackBanner extends StatelessWidget {
  final String message;
  final FeedbackType type;

  const FeedbackBanner({
    super.key,
    required this.message,
    required this.type,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case FeedbackType.success:
        return AppColors.success.withOpacity(0.1);
      case FeedbackType.error:
        return AppColors.error.withOpacity(0.1);
      case FeedbackType.warning:
        return AppColors.warning.withOpacity(0.1);
      case FeedbackType.info:
        return AppColors.primary.withOpacity(0.1);
      case FeedbackType.initial:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.info:
        return AppColors.primary;
      case FeedbackType.initial:
        return AppColors.textSecondary;
    }
  }

  IconData? _getIcon() {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle_outline;
      case FeedbackType.error:
        return Icons.error_outline;
      case FeedbackType.warning:
        return Icons.warning_amber_outlined;
      case FeedbackType.info:
        return Icons.info_outline;
      case FeedbackType.initial:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getTextColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getTextColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}