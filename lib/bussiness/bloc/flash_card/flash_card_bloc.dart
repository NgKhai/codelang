

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/flash_card_service.dart';
import 'flash_card_event.dart';
import 'flash_card_state.dart';

class FlashCardBloc extends Bloc<FlashCardEvent, FlashCardState> {
  final FlashCardService flashCardService;

  FlashCardBloc({required this.flashCardService}) : super(const FlashCardState()) {
    on<LoadFlashCards>(_onLoadFlashCards);
    on<LoadMoreFlashCards>(_onLoadMoreFlashCards);
    on<RefreshFlashCards>(_onRefreshFlashCards);
  }

  /// Handles initial loading of flash cards
  Future<void> _onLoadFlashCards(
      LoadFlashCards event,
      Emitter<FlashCardState> emit,
      ) async {
    emit(state.copyWith(status: FlashCardStatus.loading));

    try {
      final flashCards = await flashCardService.fetchFlashCards(page: 0);

      emit(state.copyWith(
        status: FlashCardStatus.success,
        flashCards: flashCards,
        currentPage: 0,
        hasReachedMax: flashCards.isEmpty,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FlashCardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Handles loading more flash cards (pagination)
  Future<void> _onLoadMoreFlashCards(
      LoadMoreFlashCards event,
      Emitter<FlashCardState> emit,
      ) async {
    // Don't load more if already reached max or currently loading
    if (state.hasReachedMax || state.status == FlashCardStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: FlashCardStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final newFlashCards = await flashCardService.fetchFlashCards(page: nextPage);

      if (newFlashCards.isEmpty) {
        emit(state.copyWith(
          status: FlashCardStatus.success,
          hasReachedMax: true,
        ));
      } else {
        emit(state.copyWith(
          status: FlashCardStatus.success,
          flashCards: List.of(state.flashCards)..addAll(newFlashCards),
          currentPage: nextPage,
          hasReachedMax: false,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FlashCardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Handles refreshing the flash card list
  Future<void> _onRefreshFlashCards(
      RefreshFlashCards event,
      Emitter<FlashCardState> emit,
      ) async {
    // Reset to initial state before loading
    emit(const FlashCardState(status: FlashCardStatus.loading));

    try {
      final flashCards = await flashCardService.fetchFlashCards(page: 0);

      emit(FlashCardState(
        status: FlashCardStatus.success,
        flashCards: flashCards,
        currentPage: 0,
        hasReachedMax: flashCards.isEmpty,
      ));
    } catch (error) {
      emit(FlashCardState(
        status: FlashCardStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}