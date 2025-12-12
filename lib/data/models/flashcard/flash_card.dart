class FlashCard {
  final String flashCardId;
  final String flashCardWord;
  final String flashCardPartOfSpeech;
  final String flashCardPronunciation;
  final String flashCardImageUrl;
  final String flashCardDefinition;
  final String flashCardExampleSentence;
  final String flashCardExampleTranslation;
  final String practiceType;

  const FlashCard({
    required this.flashCardId,
    required this.flashCardWord,
    required this.flashCardPartOfSpeech,
    required this.flashCardPronunciation,
    required this.flashCardImageUrl,
    required this.flashCardDefinition,
    required this.flashCardExampleSentence,
    required this.flashCardExampleTranslation,
    required this.practiceType,
  });

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      flashCardId: json['flashCardId'] as String,
      flashCardWord: json['flashCardWord'] as String,
      flashCardPartOfSpeech: json['flashCardPartOfSpeech'] as String,
      flashCardPronunciation: json['flashCardPronunciation'] as String,
      flashCardImageUrl: json['flashCardImageUrl'] as String,
      flashCardDefinition: json['flashCardDefinition'] as String,
      flashCardExampleSentence: json['flashCardExampleSentence'] as String,
      flashCardExampleTranslation: json['flashCardExampleTranslation'] as String,
      practiceType: json['practiceType'] as String? ?? '',
    );
  }
}