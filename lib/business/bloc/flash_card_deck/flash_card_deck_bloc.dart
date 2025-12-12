import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/flash_card_deck_service.dart';
import 'flash_card_deck_event.dart';
import 'flash_card_deck_state.dart';

class FlashCardDeckBloc extends Bloc<FlashCardDeckEvent, FlashCardDeckState> {
  final FlashCardDeckService _deckService;

  FlashCardDeckBloc({FlashCardDeckService? deckService})
      : _deckService = deckService ?? FlashCardDeckService(),
        super(const FlashCardDeckState()) {
    on<LoadFlashCardDecks>(_onLoadDecks);
    on<RefreshFlashCardDecks>(_onRefreshDecks);
  }

  Future<void> _onLoadDecks(
    LoadFlashCardDecks event,
    Emitter<FlashCardDeckState> emit,
  ) async {
    if (state.status == FlashCardDeckStatus.loading) return;

    emit(state.copyWith(status: FlashCardDeckStatus.loading));

    try {
      final decks = await _deckService.fetchAllDecks();
      emit(state.copyWith(
        status: FlashCardDeckStatus.success,
        decks: decks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FlashCardDeckStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshDecks(
    RefreshFlashCardDecks event,
    Emitter<FlashCardDeckState> emit,
  ) async {
    emit(state.copyWith(status: FlashCardDeckStatus.loading));

    try {
      final decks = await _deckService.fetchAllDecks();
      emit(state.copyWith(
        status: FlashCardDeckStatus.success,
        decks: decks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FlashCardDeckStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
