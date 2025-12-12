import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'package:codelang/data/models/flashcard/flash_card_deck.dart';
import 'mongo_service.dart';

class FlashCardDeckService {
  final MongoService _mongoService = MongoService.instance;

  /// Fetches all flash card decks from MongoDB
  Future<List<FlashCardDeck>> fetchAllDecks() async {
    final decksData = await _mongoService.fetchFlashCardDecks();
    return decksData.map((data) => FlashCardDeck.fromJson(data)).toList();
  }

  /// Fetches a single flash card deck by ID
  Future<FlashCardDeck?> fetchDeckById(String deckId) async {
    final data = await _mongoService.fetchFlashCardDeckById(deckId);
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

    final cardsData = await _mongoService.fetchFlashCardsByIds(deck.cardIds);
    return cardsData.map((data) => FlashCard.fromJson(data)).toList();
  }
}
