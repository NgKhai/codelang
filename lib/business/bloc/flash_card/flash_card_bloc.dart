import 'package:codelang/data/services/flash_card_service.dart';
import 'package:codelang/data/services/flash_card_deck_service.dart';
import 'package:codelang/data/services/tts_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'flash_card_event.dart';
import 'flash_card_state.dart';

class FlashCardBloc extends Bloc<FlashCardEvent, FlashCardState> {
  final FlashCardService flashCardService;
  final FlashCardDeckService deckService;
  final TtsService ttsService;

  FlashCardBloc({
    required this.flashCardService,
    required this.ttsService,
    FlashCardDeckService? deckService,
  }) : deckService = deckService ?? FlashCardDeckService(),
       super(const FlashCardState()) {
    on<LoadFlashCards>(_onLoadFlashCards);
    on<LoadMoreFlashCards>(_onLoadMoreFlashCards);
    on<RefreshFlashCards>(_onRefreshFlashCards);
    on<SpeakFlashCardWord>(_onSpeakFlashCardWord);
    on<StopSpeaking>(_onStopSpeaking);
  }

  /// Handles initial loading of flash cards
  Future<void> _onLoadFlashCards(
      LoadFlashCards event,
      Emitter<FlashCardState> emit,
      ) async {
    emit(state.copyWith(status: FlashCardStatus.loading, deckId: event.deckId));

    try {
      var flashCards = event.deckId != null
          ? await deckService.fetchCardsForDeck(event.deckId!)
          : await flashCardService.fetchFlashCards(page: 0);

      if (event.shuffle) {
        flashCards = List.of(flashCards)..shuffle();
      }

      emit(state.copyWith(
        status: FlashCardStatus.success,
        flashCards: flashCards,
        currentPage: 0,
        hasReachedMax: event.deckId != null || flashCards.isEmpty,
        deckId: event.deckId,
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

  /// Handles speaking a flash card word
  Future<void> _onSpeakFlashCardWord(
      SpeakFlashCardWord event,
      Emitter<FlashCardState> emit,
      ) async {
    // Don't speak if already speaking
    if (state.isSpeaking) return;

    emit(state.copyWith(
      isSpeaking: true,
      speakingWord: event.word,
    ));

    try {
      await ttsService.speakWithSettings(
        word: event.word,
        language: event.language ?? TtsLanguages.englishUS,
        speechRate: event.speechRate ?? TtsSpeechRates.normal,
      );

      // Wait a bit before resetting to give visual feedback
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        isSpeaking: false,
        speakingWord: null,
      ));
    } catch (error) {
      print('Error speaking word: $error');
      emit(state.copyWith(
        isSpeaking: false,
        speakingWord: null,
      ));
    }
  }

  /// Handles stopping speech
  Future<void> _onStopSpeaking(
      StopSpeaking event,
      Emitter<FlashCardState> emit,
      ) async {
    await ttsService.stop();
    emit(state.copyWith(
      isSpeaking: false,
      speakingWord: null,
    ));
  }

  @override
  Future<void> close() {
    ttsService.dispose();
    return super.close();
  }
}