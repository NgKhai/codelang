import 'package:codelang/data/services/flash_card_service.dart';
import 'package:codelang/presentation/widgets/flash_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../../business/bloc/flash_card/flash_card_event.dart';
import '../../../business/bloc/flash_card/flash_card_state.dart';
import '../../../data/services/tts_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/custom_app_bar.dart';

/// Screen to view all cards in a deck (no rating, just browsing)
class FlashCardScreen extends StatelessWidget {
  final String? deckId;
  final String? deckName;

  const FlashCardScreen({super.key, this.deckId, this.deckName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashCardBloc(
        flashCardService: FlashCardService(),
        ttsService: TtsService(),
      )..add(LoadFlashCards(deckId: deckId)),
      child: _FlashCardView(deckId: deckId, deckName: deckName),
    );
  }
}

class _FlashCardView extends StatefulWidget {
  final String? deckId;
  final String? deckName;

  const _FlashCardView({this.deckId, this.deckName});

  @override
  State<_FlashCardView> createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<_FlashCardView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      // Load more cards for THIS deck only
      context.read<FlashCardBloc>().add(LoadMoreFlashCards(deckId: widget.deckId));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarStyles.practice(
        showBackButton: true,
        onLeadingIconPressed: () => context.pop(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE8ECF2)],
          ),
        ),
        child: Column(
          children: [
            // Start Practice Header
            _buildPracticeHeader(context, isDark),

            // Cards list
            Expanded(
              child: BlocBuilder<FlashCardBloc, FlashCardState>(
                builder: (context, state) {
                  switch (state.status) {
                    case FlashCardStatus.initial:
                    case FlashCardStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );

                    case FlashCardStatus.failure:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load flash cards',
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
                                // Refresh with current deck only
                                context.read<FlashCardBloc>().add(
                                  LoadFlashCards(deckId: widget.deckId),
                                );
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

                    case FlashCardStatus.success:
                    case FlashCardStatus.loadingMore:
                      if (state.flashCards.isEmpty) {
                        return Center(
                          child: Text(
                            'No flash cards available',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // Refresh with current deck only - fixed!
                          context.read<FlashCardBloc>().add(
                            LoadFlashCards(deckId: widget.deckId),
                          );
                          await context.read<FlashCardBloc>().stream.firstWhere(
                                (state) => state.status == FlashCardStatus.success ||
                                    state.status == FlashCardStatus.failure,
                          );
                        },
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.hasReachedMax
                              ? state.flashCards.length
                              : state.flashCards.length + 1,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index >= state.flashCards.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: state.status == FlashCardStatus.loadingMore
                                      ? const CircularProgressIndicator(
                                          color: AppColors.primary)
                                      : Text(
                                          "Pull down to refresh",
                                          style: TextStyle(
                                            color: isDark ? Colors.white54 : Colors.grey,
                                          ),
                                        ),
                                ),
                              );
                            }

                            final entry = state.flashCards[index];
                            // No rating callback - just viewing
                            return FlashCardWidget(entry: entry);
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.deckName ?? 'Flash Cards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<FlashCardBloc, FlashCardState>(
                  builder: (context, state) {
                    return Text(
                      '${state.flashCards.length} words',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.deckId != null) {
                context.push(
                  '/flashcards/${widget.deckId}/practice',
                  extra: {'deckName': widget.deckName},
                );
              }
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}