import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/offline/offline_bloc.dart';
import '../../../business/bloc/offline/offline_event.dart';
import '../../../business/bloc/offline/offline_state.dart';
import '../../../data/models/offline/offline_course.dart';
import '../../../data/models/offline/offline_flash_card_deck.dart';
import '../../../data/services/offline_storage_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';

/// Screen for managing downloaded offline content
class DownloadedContentScreen extends StatelessWidget {
  const DownloadedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? const Color(0xFF121212) 
        : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Downloaded Content',
        showBackButton: true,
        leadingIcon: Icons.arrow_back,
        onLeadingIconPressed: () => context.pop(),
      ),
      body: BlocBuilder<OfflineBloc, OfflineState>(
        builder: (context, state) {
          if (state.status == OfflineStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalItems = state.downloadedCourses.length + 
                            state.downloadedDecks.length;

          if (totalItems == 0) {
            return _buildEmptyState(isDark, textColor);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<OfflineBloc>().add(const LoadDownloadedContent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Storage info
                  _buildStorageInfo(totalItems, cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Courses section
                  if (state.downloadedCourses.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Courses',
                      state.downloadedCourses.length,
                      textColor,
                    ),
                    const SizedBox(height: 12),
                    ...state.downloadedCourses.map((course) => 
                      _buildCourseItem(context, course, cardColor, textColor, isDark)),
                    const SizedBox(height: 24),
                  ],

                  // Flash Card Decks section
                  if (state.downloadedDecks.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Flash Card Decks',
                      state.downloadedDecks.length,
                      textColor,
                    ),
                    const SizedBox(height: 12),
                    ...state.downloadedDecks.map((deck) => 
                      _buildDeckItem(context, deck, cardColor, textColor, isDark)),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_for_offline_outlined,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Downloaded Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Download courses or flash card decks\nto use them offline',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(
    int totalItems,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    final storageSize = OfflineStorageService.formattedStorageSize;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storage_rounded,
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
                  '$totalItems items downloaded',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Storage used: $storageSize',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Storage size badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  storageSize,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color textColor) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(
    BuildContext context,
    OfflineCourse course,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.book_rounded,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        title: Text(
          course.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          'Downloaded ${_formatDate(course.downloadedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.5),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: AppColors.error,
          ),
          onPressed: () => _showDeleteDialog(
            context,
            'course',
            course.name,
            () => context.read<OfflineBloc>().add(
              DeleteCourse(courseId: course.id),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeckItem(
    BuildContext context,
    OfflineFlashCardDeck deck,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.style_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          deck.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          '${deck.cardCount} cards • Downloaded ${_formatDate(deck.downloadedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.5),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: AppColors.error,
          ),
          onPressed: () => _showDeleteDialog(
            context,
            'deck',
            deck.name,
            () => context.read<OfflineBloc>().add(
              DeleteDeck(deckId: deck.deckId),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    String type,
    String name,
    VoidCallback onConfirm,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Delete $type?'),
        content: Text(
          'Are you sure you want to delete "$name" from your downloads?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
