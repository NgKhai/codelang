// lib/data/services/flash_card_service.dart
// Updated to use REST API instead of direct MongoDB

import 'package:codelang/data/models/flashcard/flash_card.dart';
import 'api_service.dart';

class FlashCardService {
  static const int pageSize = 5;
  final ApiService _apiService = ApiService.instance;

  /// Fetches a page of flash cards from API
  Future<List<FlashCard>> fetchFlashCards({
    required int page,
    int limit = pageSize,
  }) async {
    final flashCardsData = await _apiService.fetchFlashCards(
      page: page,
      limit: limit,
    );

    return flashCardsData
        .map((data) => FlashCard.fromJson(data))
        .toList();
  }

  /// Fetches a single flash card by ID from API
  Future<FlashCard?> fetchFlashCardById(String id) async {
    final data = await _apiService.fetchFlashCardById(id);
    
    if (data == null) {
      return null;
    }

    return FlashCard.fromJson(data);
  }

  /// Gets the total count of flash cards
  Future<int> getTotalCount() async {
    return await _apiService.getFlashCardsCount();
  }

  /// Fetches flash cards by a list of IDs
  Future<List<FlashCard>> fetchFlashCardsByIds(List<String> ids) async {
    final flashCardsData = await _apiService.fetchFlashCardsByIds(ids);
    
    return flashCardsData
        .map((data) => FlashCard.fromJson(data))
        .toList();
  }
}