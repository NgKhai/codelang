import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:codelang/data/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../business/bloc/flash_card/flash_card_event.dart';
import '../../business/bloc/flash_card/flash_card_state.dart';
import '../../style/app_colors.dart';

class FlashCardWidget extends StatelessWidget {
  final FlashCard entry;
  final String? deckId;
  final Function(String cardId, int quality)? onRated;

  const FlashCardWidget({
    super.key,
    required this.entry,
    this.deckId,
    this.onRated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get screen dimensions using MediaQuery
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Calculate a responsive image height based on screen width
    double calculatedImageHeight = screenWidth * 0.5;
    calculatedImageHeight = calculatedImageHeight.clamp(180.0, 280.0);

    return BlocBuilder<FlashCardBloc, FlashCardState>(
      buildWhen: (previous, current) {
        // Only rebuild if the speaking state changed for this specific word
        return previous.isSpeaking != current.isSpeaking &&
            (current.speakingWord == entry.flashCardWord ||
                previous.speakingWord == entry.flashCardWord);
      },
      builder: (context, state) {
        final isSpeaking =
            state.isSpeaking && state.speakingWord == entry.flashCardWord;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    child: Image.network(
                      entry.flashCardImageUrl,
                      height: calculatedImageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/codelang.png',
                          height: calculatedImageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Absolute fallback if asset also fails
                            return Container(
                              height: calculatedImageHeight,
                              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F2F5),
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined, size: 48),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Word Overlay
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.flashCardWord,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 4.0,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 8.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.flashCardPartOfSpeech,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 2.0,
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.flashCardPronunciation,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.95),
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black.withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Audio Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSpeaking
                                    ? Icons.volume_up
                                    : Icons.volume_up_outlined,
                                key: ValueKey(isSpeaking),
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            onPressed: isSpeaking
                                ? null
                                : () {
                                    context.read<FlashCardBloc>().add(
                                      SpeakFlashCardWord(
                                        word: entry.flashCardWord,
                                        language: TtsLanguages.englishUS,
                                        speechRate: TtsSpeechRates.normal,
                                      ),
                                    );
                                  },
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(),
                            tooltip: 'Pronounce word',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Definition
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Definition',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.flashCardDefinition,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                    const SizedBox(height: 24),

                    // Example
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Example',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.flashCardExampleSentence,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.flashCardExampleTranslation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Rating buttons (only show if callback provided)
                    if (onRated != null) ...[
                      const SizedBox(height: 24),
                      Divider(
                        height: 1,
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How well did you know this?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // 2x2 Grid layout for rating buttons
                      Column(
                        children: [
                          // Top row: Easy (left), Good (right)
                          Row(
                            children: [
                              Expanded(
                                child: _buildRatingButton(
                                  context: context,
                                  label: 'Easy',
                                  color: AppColors.success,
                                  quality: 5,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRatingButton(
                                  context: context,
                                  label: 'Good',
                                  color: AppColors.accent,
                                  quality: 4,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Bottom row: Hard (left), Again (right)
                          Row(
                            children: [
                              Expanded(
                                child: _buildRatingButton(
                                  context: context,
                                  label: 'Hard',
                                  color: AppColors.warning,
                                  quality: 3,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRatingButton(
                                  context: context,
                                  label: 'Again',
                                  color: AppColors.error,
                                  quality: 0,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingButton({
    required BuildContext context,
    required String label,
    required Color color,
    required int quality,
    required bool isDark,
  }) {
    return ElevatedButton(
      onPressed: () {
        onRated?.call(entry.flashCardId, quality);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
