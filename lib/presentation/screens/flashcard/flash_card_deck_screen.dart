import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../business/bloc/flash_card_deck/flash_card_deck_bloc.dart';
import '../../../business/bloc/flash_card_deck/flash_card_deck_event.dart';
import '../../../business/bloc/flash_card_deck/flash_card_deck_state.dart';
import '../../../business/bloc/offline/offline_bloc.dart';
import '../../../business/bloc/offline/offline_event.dart';
import '../../../business/bloc/offline/offline_state.dart';
import '../../../data/models/flashcard/flash_card_deck.dart';
import '../../../data/models/offline/offline_flash_card_deck.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/flash_card_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';
import '../../../data/models/flashcard/flash_card.dart';
import '../../../data/services/offline_storage_service.dart';
import '../../widgets/deck_stats_bottom_sheet.dart';
import 'flash_card_screen.dart';

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

  /// Check if we should use offline mode
  bool _shouldUseOfflineMode(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthOffline) return true;
    return !ConnectivityService().isOnline;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    final authState = context.watch<AuthBloc>().state;
    final isOfflineMode = authState is AuthOffline || !ConnectivityService().isOnline;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarStyles.practice(

      ),
      body: Column(
        children: [
          // Offline Mode Banner
          if (isOfflineMode)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Offline Mode - Showing downloaded decks',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: isOfflineMode
                ? _buildOfflineContent(context, isDark, backgroundColor)
                : _buildOnlineContent(context, isDark, backgroundColor),
          ),
        ],
      ),
    );
  }

  /// Build content from downloaded offline decks
  Widget _buildOfflineContent(BuildContext context, bool isDark, Color backgroundColor) {
    return BlocBuilder<OfflineBloc, OfflineState>(
      builder: (context, offlineState) {
        final downloadedDecks = offlineState.downloadedDecks;

        if (downloadedDecks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_download_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Downloaded Decks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download flash card decks while online to access them offline',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: downloadedDecks.length,
            itemBuilder: (context, index) {
              final offlineDeck = downloadedDecks[index];
              // Convert OfflineFlashCardDeck to FlashCardDeck for display
              final deck = FlashCardDeck(
                deckId: offlineDeck.deckId,
                name: offlineDeck.name,
                cardIds: offlineDeck.cardIds,
              );
              return _DeckCard(deck: deck, index: index);
            },
          ),
        );
      },
    );
  }

  /// Build content from online API
  Widget _buildOnlineContent(BuildContext context, bool isDark, Color backgroundColor) {
    return BlocBuilder<FlashCardDeckBloc, FlashCardDeckState>(
      builder: (context, state) {
        switch (state.status) {
          case FlashCardDeckStatus.initial:
          case FlashCardDeckStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );

          case FlashCardDeckStatus.failure:
            // If online fetch fails, try to show offline content
            return _buildOfflineContent(context, isDark, backgroundColor);

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

            // Show content directly without refresh capability
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: state.decks.length,
              itemBuilder: (context, index) {
                final deck = state.decks[index];
                return _DeckCard(deck: deck, index: index);
              },
            ),
          );
        }
      },
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

    return BlocBuilder<OfflineBloc, OfflineState>(
      builder: (context, offlineState) {
        final isDownloaded = offlineState.isDeckDownloaded(deck.deckId);
        final isDownloading = offlineState.isDownloading(deck.deckId);
        final hasUpdate = offlineState.deckHasUpdate(deck.deckId);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Check if user is in guest or offline mode
              final authState = context.read<AuthBloc>().state;
              final isOffline = !ConnectivityService().isOnline;
              final isGuestOrOffline = authState is AuthGuest || authState is AuthOffline || isOffline;
              
              if (isGuestOrOffline) {
                 // Check if deck is downloaded to get cards
                 List<FlashCard>? offlineCards;
                 if (isDownloaded) {
                    final offlineDeck = OfflineStorageService.getDeck(deck.deckId);
                    if (offlineDeck != null) {
                      offlineCards = offlineDeck.cardsData
                          .map((data) => FlashCard.fromJson(data))
                          .toList();
                    }
                 }
                 
                 // Navigate directly to practice screen
                 Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FlashCardScreen(
                        deckId: deck.deckId,
                        deckName: deck.name,
                        flashCards: offlineCards,
                      ),
                    ),
                 );
              } else {
                // Show stats bottom sheet instead of navigating directly
                DeckStatsBottomSheet.show(context, deck.deckId, deck.name);
              }
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and download button row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            deck.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildDownloadButton(
                          context: context,
                          isDownloaded: isDownloaded,
                          isDownloading: isDownloading,
                          hasUpdate: hasUpdate,
                          onDownload: () => _downloadDeck(context, deck),
                        ),
                      ],
                    ),
                    // Card count badge
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
      },
    );
  }

  Widget _buildDownloadButton({
    required BuildContext context,
    required bool isDownloaded,
    required bool isDownloading,
    required bool hasUpdate,
    required VoidCallback onDownload,
  }) {
    if (isDownloading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isDownloaded && hasUpdate) {
      return GestureDetector(
        onTap: onDownload,
        child: Icon(
          Icons.sync_rounded,
          color: AppColors.warning,
          size: 20,
        ),
      );
    }

    if (isDownloaded) {
      return Icon(
        Icons.download_done_rounded,
        color: AppColors.success,
        size: 20,
      );
    }

    return GestureDetector(
      onTap: onDownload,
      child: Icon(
        Icons.download_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Future<void> _downloadDeck(BuildContext context, FlashCardDeck deck) async {
    // Fetch cards from service
    final flashCardService = FlashCardService();
    
    try {
      final cards = await flashCardService.fetchFlashCardsByIds(deck.cardIds);

      // Convert cards to JSON
      final cardsData = cards.map((card) => {
        'flashCardId': card.flashCardId,
        'flashCardWord': card.flashCardWord,
        'flashCardPartOfSpeech': card.flashCardPartOfSpeech,
        'flashCardPronunciation': card.flashCardPronunciation,
        'flashCardImageUrl': card.flashCardImageUrl,
        'flashCardDefinition': card.flashCardDefinition,
        'flashCardExampleSentence': card.flashCardExampleSentence,
        'flashCardExampleTranslation': card.flashCardExampleTranslation,
        'practiceType': card.practiceType,
      }).toList();

      if (context.mounted) {
        context.read<OfflineBloc>().add(DownloadDeck(
          deckId: deck.deckId,
          deckName: deck.name,
          cardsData: cardsData,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading "${deck.name}"...'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
