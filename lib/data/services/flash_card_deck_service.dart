// lib/data/services/flash_card_deck_service.dart
// Updated to use REST API instead of direct MongoDB

import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:codelang/data/models/flashcard/flash_card_deck.dart';
import 'api_service.dart';

class FlashCardDeckService {
  final ApiService _apiService = ApiService.instance;

  /// Fetches all flash card decks from API
  Future<List<FlashCardDeck>> fetchAllDecks() async {
    final decksData = await _apiService.fetchFlashCardDecks();
    return decksData.map((data) => FlashCardDeck.fromJson(data)).toList();
  }

  /// Fetches a single flash card deck by ID
  Future<FlashCardDeck?> fetchDeckById(String deckId) async {
    final data = await _apiService.fetchFlashCardDeckById(deckId);
    if (data == null) {
      return null;
    }
    return FlashCardDeck.fromJson(data);
  }

  /// Fetches all flash cards for a specific deck
  Future<List<FlashCard>> fetchCardsForDeck(String deckId) async {
    final deck = await fetchDeckById(deckId);
    if (deck == null || deck.cardIds.isEmpty) {
      return [];
    }

    final cardsData = await _apiService.fetchFlashCardsByIds(deck.cardIds);
    return cardsData.map((data) => FlashCard.fromJson(data)).toList();
  }
}
