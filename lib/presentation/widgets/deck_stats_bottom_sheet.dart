import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/flash_card_stats/flash_card_stats_bloc.dart';
import '../../../business/bloc/flash_card_stats/flash_card_stats_event.dart';
import '../../../business/bloc/flash_card_stats/flash_card_stats_state.dart';
import '../../../data/models/flashcard/deck_statistics.dart';
import '../../../style/app_colors.dart';

/// Bottom sheet that displays deck statistics and allows starting practice
class DeckStatsBottomSheet extends StatelessWidget {
  final String deckId;
  final String deckName;

  const DeckStatsBottomSheet({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  static Future<void> show(BuildContext context, String deckId, String deckName) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => FlashCardStatsBloc()
          ..add(LoadDeckStats(deckId: deckId, deckName: deckName)),
        child: DeckStatsBottomSheet(deckId: deckId, deckName: deckName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<FlashCardStatsBloc, FlashCardStatsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  deckName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Stats content
                if (state.status == FlashCardStatsStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.status == FlashCardStatsStatus.failure)
                  _buildErrorState(context, state.errorMessage, textColor)
                else if (state.stats != null)
                  _buildStatsContent(context, state.stats!, isDark, textColor),

                const SizedBox(height: 24),

                // Start Practice button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      '/flashcards/$deckId',
                      extra: {'deckName': deckName},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Practice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? error, Color textColor) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          error ?? 'Failed to load stats',
          style: TextStyle(color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    DeckStatistics stats,
    bool isDark,
    Color textColor,
  ) {
    return Column(
      children: [
        // Progress circle
        _buildProgressCircle(stats, isDark),
        const SizedBox(height: 24),

        // Stats grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fiber_new_rounded,
                label: 'New',
                value: stats.newCount,
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.school_rounded,
                label: 'Learning',
                value: stats.learningCount,
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.refresh_rounded,
                label: 'Reviewing',
                value: stats.reviewingCount,
                color: AppColors.accent,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_rounded,
                label: 'Mastered',
                value: stats.masteredCount,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        ),

        if (stats.dueForReviewCount > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${stats.dueForReviewCount} cards due for review',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressCircle(DeckStatistics stats, bool isDark) {
    final progress = stats.completionPercentage / 100;
    
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${stats.completionPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Mastered',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
