import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:codelang/data/services/flash_card_service.dart';
import 'package:codelang/presentation/widgets/flash_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../../business/bloc/flash_card/flash_card_event.dart';
import '../../../business/bloc/flash_card/flash_card_state.dart';
import '../../../business/bloc/flash_card_stats/flash_card_stats_bloc.dart';
import '../../../business/bloc/flash_card_stats/flash_card_stats_event.dart';
import '../../../data/services/tts_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';

/// Practice screen with SM-2 rating buttons
class FlashCardPracticeScreen extends StatelessWidget {
  final String deckId;
  final String? deckName;

  const FlashCardPracticeScreen({
    super.key,
    required this.deckId,
    this.deckName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FlashCardBloc(
            flashCardService: FlashCardService(),
            ttsService: TtsService(),
          )..add(LoadFlashCards(deckId: deckId, shuffle: true)),
        ),
        BlocProvider(create: (context) => FlashCardStatsBloc()),
      ],
      child: _PracticeView(deckId: deckId, deckName: deckName),
    );
  }
}

class _PracticeView extends StatefulWidget {
  final String deckId;
  final String? deckName;

  const _PracticeView({required this.deckId, this.deckName});

  @override
  State<_PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<_PracticeView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCardRated(String cardId, int quality) {
    context.read<FlashCardStatsBloc>().add(
      UpdateCardProgress(
        deckId: widget.deckId,
        flashCardId: cardId,
        quality: quality,
      ),
    );

    // Show feedback and move to next card
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getRatingFeedback(quality)),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getRatingColor(quality),
      ),
    );

    // Move to next card after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final state = context.read<FlashCardBloc>().state;
      if (_currentIndex < state.flashCards.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Finished all cards
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Complete! 🎉'),
        content: const Text('You have reviewed all cards in this deck.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Back to Deck'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FlashCardBloc>().add(
                LoadFlashCards(deckId: widget.deckId, shuffle: true),
              );
              setState(() => _currentIndex = 0);
              _pageController.jumpToPage(0);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  String _getRatingFeedback(int quality) {
    switch (quality) {
      case 0:
        return 'Will review again soon';
      case 3:
        return 'Got it, but it was hard';
      case 4:
        return 'Good job!';
      case 5:
        return 'Perfect recall!';
      default:
        return 'Recorded';
    }
  }

  Color _getRatingColor(int quality) {
    switch (quality) {
      case 0:
        return AppColors.error;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.accent;
      case 5:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: widget.deckName ?? 'Practice',
        showBackButton: true,
        leadingIcon: Icons.abc,
        onLeadingIconPressed: () => context.pop(),
      ),
      body: BlocBuilder<FlashCardBloc, FlashCardState>(
        builder: (context, state) {
          if (state.status == FlashCardStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.flashCards.isEmpty) {
            return Center(
              child: Text(
                'No cards to practice',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${state.flashCards.length}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / state.flashCards.length,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Card viewer
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemCount: state.flashCards.length,
                  itemBuilder: (context, index) {
                    final card = state.flashCards[index];
                    return SingleChildScrollView(
                      child: FlashCardWidget(
                        entry: card,
                        deckId: widget.deckId,
                        onRated: _onCardRated,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
