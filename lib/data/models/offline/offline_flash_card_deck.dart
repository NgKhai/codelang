import 'dart:convert';
import 'package:hive/hive.dart';

part 'offline_flash_card_deck.g.dart';

/// Hive adapter for storing flash card decks offline
/// Stores all cards embedded within the deck
@HiveType(typeId: 1)
class OfflineFlashCardDeck extends HiveObject {
  @HiveField(0)
  final String deckId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String cardsJson; // Serialized flash cards as JSON

  @HiveField(3)
  final int cardCount;

  @HiveField(4)
  final String version; // For update detection (hash of content)

  @HiveField(5)
  final DateTime downloadedAt;

  OfflineFlashCardDeck({
    required this.deckId,
    required this.name,
    required this.cardsJson,
    required this.cardCount,
    required this.version,
    required this.downloadedAt,
  });

  /// Create from server data with version hash
  factory OfflineFlashCardDeck.fromServerData({
    required String deckId,
    required String name,
    required List<Map<String, dynamic>> cardsData,
  }) {
    final jsonStr = jsonEncode(cardsData);
    // Create a simple version hash from content
    final version = jsonStr.hashCode.toString();
    
    return OfflineFlashCardDeck(
      deckId: deckId,
      name: name,
      cardsJson: jsonStr,
      cardCount: cardsData.length,
      version: version,
      downloadedAt: DateTime.now(),
    );
  }

  /// Get cards as parsed JSON list
  List<Map<String, dynamic>> get cardsData {
    try {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Get card IDs from stored cards
  List<String> get cardIds {
    try {
      final cards = cardsData;
      return cards.map((card) => 
        card['flashCardId']?.toString() ?? 
        card['_id']?.toString() ?? 
        card['id']?.toString() ?? ''
      ).where((id) => id.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if local version differs from server version
  bool hasUpdate(String serverVersion) {
    return version != serverVersion;
  }
}
