import 'package:codelang/data/models/flash_card.dart';

class FlashCardService {
  static const int pageSize = 5;
  static const int maxItems = 50; // Simulate a max number of items

  /// Fetches a page of flash cards
  /// In a real app, this would call an API endpoint
  Future<List<FlashCard>> fetchFlashCards({
    required int page,
    int limit = pageSize,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate reaching the end of data
    final startIndex = page * limit + 1;
    if (startIndex > maxItems) {
      return [];
    }

    // Calculate how many items to return
    final remainingItems = maxItems - (page * limit);
    final itemsToReturn = remainingItems < limit ? remainingItems : limit;

    if (itemsToReturn <= 0) {
      return [];
    }

    // Generate dummy flash cards
    return _generateFlashCards(startIndex, itemsToReturn);
  }

  /// Generates dummy flash card data
  List<FlashCard> _generateFlashCards(int start, int count) {
    return List.generate(count, (index) {
      final number = start + index;
      return FlashCard(
        flashCardId: number.toString(),
        flashCardWord: 'Word #$number',
        flashCardPartOfSpeech: '(noun)',
        flashCardPronunciation: "/'wɜːrd $number/",
        flashCardImageUrl: 'https://picsum.photos/600/300?random=$number',
        flashCardDefinition: 'Đây là định nghĩa cho từ vựng số $number.',
        flashCardExampleSentence:
        'Learning Flutter allows you to build beautiful UIs like this card for word #$number.',
        flashCardExampleTranslation:
        '(Học Flutter giúp bạn xây dựng giao diện đẹp như thẻ này cho từ #$number)',
      );
    });
  }

  /// Simulates fetching a single flash card by ID
  /// Useful for future features like favoriting or detailed view
  Future<FlashCard?> fetchFlashCardById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final numId = int.tryParse(id);
    if (numId == null || numId < 1 || numId > maxItems) {
      return null;
    }

    return FlashCard(
      flashCardId: id,
      flashCardWord: 'Word #$id',
      flashCardPartOfSpeech: '(noun)',
      flashCardPronunciation: "/'wɜːrd $id/",
      flashCardImageUrl: 'https://picsum.photos/600/300?random=$id',
      flashCardDefinition: 'Đây là định nghĩa cho từ vựng số $id.',
      flashCardExampleSentence:
      'Learning Flutter allows you to build beautiful UIs like this card for word #$id.',
      flashCardExampleTranslation:
      '(Học Flutter giúp bạn xây dựng giao diện đẹp như thẻ này cho từ #$id)',
    );
  }
}