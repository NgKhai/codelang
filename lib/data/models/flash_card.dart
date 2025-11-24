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
}