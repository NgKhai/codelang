import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'mongo_service.dart';

class FlashCardService {
  static const int pageSize = 5;
  final MongoService _mongoService = MongoService.instance;

  /// Fetches a page of flash cards from MongoDB
  Future<List<FlashCard>> fetchFlashCards({
    required int page,
    int limit = pageSize,
  }) async {
    final flashCardsData = await _mongoService.fetchFlashCards(
      page: page,
      limit: limit,
    );

    return flashCardsData
        .map((data) => FlashCard.fromJson(data))
        .toList();
  }

  /// Fetches a single flash card by ID from MongoDB
  Future<FlashCard?> fetchFlashCardById(String id) async {
    final data = await _mongoService.fetchFlashCardById(id);
    
    if (data == null) {
      return null;
    }

    return FlashCard.fromJson(data);
  }

  /// Gets the total count of flash cards
  Future<int> getTotalCount() async {
    return await _mongoService.getFlashCardsCount();
  }
}