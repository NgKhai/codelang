import 'package:codelang/data/services/flash_card_service.dart';
import 'package:codelang/presentation/widgets/flash_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../business/bloc/flash_card/flash_card_event.dart';
import '../../business/bloc/flash_card/flash_card_state.dart';
import '../../data/services/tts_service.dart';
import '../../style/custom_app_bar.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

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
    return Scaffold(
      appBar: AppBarStyles.practice(
        onFilterPressed: () {
          // TODO: Implement filter functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Filter feature coming soon!')),
          );
        },
        onSearchPressed: () {
          // TODO: Implement search functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search feature coming soon!')),
          );
        },
      ),
      body: BlocBuilder<FlashCardBloc, FlashCardState>(
        builder: (context, state) {
          switch (state.status) {
            case FlashCardStatus.initial:
            case FlashCardStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );

            case FlashCardStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load flash cards',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<FlashCardBloc>().add(const LoadFlashCards());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case FlashCardStatus.success:
            case FlashCardStatus.loadingMore:
              if (state.flashCards.isEmpty) {
                return const Center(
                  child: Text('No flash cards available'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FlashCardBloc>().add(const RefreshFlashCards());
                  // Wait for the refresh to complete
                  await context.read<FlashCardBloc>().stream.firstWhere(
                        (state) => state.status != FlashCardStatus.loading,
                  );
                },
                color: Colors.blue,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.flashCards.length
                          : state.flashCards.length + 1,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (context, index) {
                        if (index >= state.flashCards.length) {
                          // Loading indicator at the bottom
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: state.status == FlashCardStatus.loadingMore
                                  ? const CircularProgressIndicator(
                                  color: Colors.blue)
                                  : const Text(
                                "Pull down to refresh.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        final entry = state.flashCards[index];
                        return FlashCardWidget(entry: entry);
                      },
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}