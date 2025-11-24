import 'package:codelang/data/services/flash_card_service.dart';
import 'package:codelang/presentation/widgets/flash_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../business/bloc/flash_card/flash_card_event.dart';
import '../../business/bloc/flash_card/flash_card_state.dart';
import '../../data/services/tts_service.dart';
import '../../style/app_colors.dart';
import '../../style/custom_app_bar.dart';

class FlashCardScreen extends StatelessWidget {
  const FlashCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashCardBloc(
        flashCardService: FlashCardService(),
        ttsService: TtsService(),
      )..add(const LoadFlashCards()),
      child: const PracticeScreenView(),
    );
  }
}

class PracticeScreenView extends StatefulWidget {
  const PracticeScreenView({super.key});

  @override
  State<PracticeScreenView> createState() => _PracticeScreenViewState();
}

class _PracticeScreenViewState extends State<PracticeScreenView> {
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
      context.read<FlashCardBloc>().add(const LoadMoreFlashCards());
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
        onFilterPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Filter feature coming soon!')),
          );
        },
        onSearchPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search feature coming soon!')),
          );
        },
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
                          context.read<FlashCardBloc>().add(const LoadFlashCards());
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
                    context.read<FlashCardBloc>().add(const RefreshFlashCards());
                    await context.read<FlashCardBloc>().stream.firstWhere(
                          (state) => state.status != FlashCardStatus.loading,
                    );
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.hasReachedMax
                        ? state.flashCards.length
                        : state.flashCards.length + 1,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    physics: const BouncingScrollPhysics(),
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
                      return FlashCardWidget(entry: entry);
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}