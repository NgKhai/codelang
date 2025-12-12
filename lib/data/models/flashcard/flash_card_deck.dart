class FlashCardDeck {
  final String deckId;
  final String name;
  final List<String> cardIds;

  const FlashCardDeck({
    required this.deckId,
    required this.name,
    required this.cardIds,
  });

  factory FlashCardDeck.fromJson(Map<String, dynamic> json) {
    return FlashCardDeck(
      deckId: json['deckId'] as String,
      name: json['name'] as String,
      cardIds: List<String>.from(json['cardIds'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'name': name,
      'cardIds': cardIds,
    };
  }

  int get cardCount => cardIds.length;
}
