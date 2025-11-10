import 'package:equatable/equatable.dart';

class FlashCard extends Equatable {
  final String flashCardId;
  final String flashCardWord;
  final String flashCardPartOfSpeech;
  final String flashCardPronunciation;
  final String flashCardImageUrl;
  final String flashCardDefinition;
  final String flashCardExampleSentence;
  final String flashCardExampleTranslation;

  const FlashCard({
    required this.flashCardId,
    required this.flashCardWord,
    required this.flashCardPartOfSpeech,
    required this.flashCardPronunciation,
    required this.flashCardImageUrl,
    required this.flashCardDefinition,
    required this.flashCardExampleSentence,
    required this.flashCardExampleTranslation,
  });

  /// Creates a copy of this FlashCard with the given fields replaced with new values
  FlashCard copyWith({
    String? flashCardId,
    String? flashCardWord,
    String? flashCardPartOfSpeech,
    String? flashCardPronunciation,
    String? flashCardImageUrl,
    String? flashCardDefinition,
    String? flashCardExampleSentence,
    String? flashCardExampleTranslation,
  }) {
    return FlashCard(
      flashCardId: flashCardId ?? this.flashCardId,
      flashCardWord: flashCardWord ?? this.flashCardWord,
      flashCardPartOfSpeech: flashCardPartOfSpeech ?? this.flashCardPartOfSpeech,
      flashCardPronunciation: flashCardPronunciation ?? this.flashCardPronunciation,
      flashCardImageUrl: flashCardImageUrl ?? this.flashCardImageUrl,
      flashCardDefinition: flashCardDefinition ?? this.flashCardDefinition,
      flashCardExampleSentence: flashCardExampleSentence ?? this.flashCardExampleSentence,
      flashCardExampleTranslation: flashCardExampleTranslation ?? this.flashCardExampleTranslation,
    );
  }

  /// Creates a FlashCard from JSON
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
    );
  }

  /// Converts this FlashCard to JSON
  Map<String, dynamic> toJson() {
    return {
      'flashCardId': flashCardId,
      'flashCardWord': flashCardWord,
      'flashCardPartOfSpeech': flashCardPartOfSpeech,
      'flashCardPronunciation': flashCardPronunciation,
      'flashCardImageUrl': flashCardImageUrl,
      'flashCardDefinition': flashCardDefinition,
      'flashCardExampleSentence': flashCardExampleSentence,
      'flashCardExampleTranslation': flashCardExampleTranslation,
    };
  }

  @override
  List<Object?> get props => [
    flashCardId,
    flashCardWord,
    flashCardPartOfSpeech,
    flashCardPronunciation,
    flashCardImageUrl,
    flashCardDefinition,
    flashCardExampleSentence,
    flashCardExampleTranslation,
  ];
}