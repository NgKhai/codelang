import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/flash_card_deck/flash_card_deck_bloc.dart';
import '../../../business/bloc/flash_card_deck/flash_card_deck_event.dart';
import '../../../business/bloc/flash_card_deck/flash_card_deck_state.dart';
import '../../../data/models/flashcard/flash_card_deck.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';
import '../../widgets/deck_stats_bottom_sheet.dart';

class FlashCardDeckScreen extends StatelessWidget {
  const FlashCardDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashCardDeckBloc()..add(const LoadFlashCardDecks()),
      child: const _FlashCardDeckView(),
    );
  }
}

class _FlashCardDeckView extends StatelessWidget {
  const _FlashCardDeckView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarStyles.practice(

      ),
      body: BlocBuilder<FlashCardDeckBloc, FlashCardDeckState>(
        builder: (context, state) {
          switch (state.status) {
            case FlashCardDeckStatus.initial:
            case FlashCardDeckStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );

            case FlashCardDeckStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load decks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<FlashCardDeckBloc>().add(const LoadFlashCardDecks());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case FlashCardDeckStatus.success:
              if (state.decks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 64,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No decks available',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FlashCardDeckBloc>().add(const RefreshFlashCardDecks());
                  await context.read<FlashCardDeckBloc>().stream.firstWhere(
                        (state) => state.status != FlashCardDeckStatus.loading,
                  );
                },
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: state.decks.length,
                    itemBuilder: (context, index) {
                      final deck = state.decks[index];
                      return _DeckCard(deck: deck, index: index);
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final FlashCardDeck deck;
  final int index;

  const _DeckCard({required this.deck, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Show stats bottom sheet instead of navigating directly
          DeckStatsBottomSheet.show(context, deck.deckId, deck.name);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deck.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deck.cardCount} cards',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
