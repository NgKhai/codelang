// lib/data/models/alc/alc_result.dart
// Active Lingo Coach result model

class AlcResult {
  final String originalIntent;
  final String detectedLanguage;
  final int professionalScore;
  final int clarityScore;
  final int toneScore;
  final String critique;
  final String suggestion;
  final String suggestedCommunicationType;
  final String suggestedSeverity;
  final List<String> keyTermHighlight;
  final List<AlternativeVersion> alternativeVersions;

  AlcResult({
    required this.originalIntent,
    required this.detectedLanguage,
    required this.professionalScore,
    required this.clarityScore,
    required this.toneScore,
    required this.critique,
    required this.suggestion,
    required this.suggestedCommunicationType,
    required this.suggestedSeverity,
    required this.keyTermHighlight,
    required this.alternativeVersions,
  });

  factory AlcResult.fromJson(Map<String, dynamic> json) {
    return AlcResult(
      originalIntent: json['originalIntent'] ?? '',
      detectedLanguage: json['detectedLanguage'] ?? 'casual_english',
      professionalScore: json['professionalScore'] ?? 0,
      clarityScore: json['clarityScore'] ?? 0,
      toneScore: json['toneScore'] ?? 0,
      critique: json['critique'] ?? '',
      suggestion: json['suggestion'] ?? '',
      suggestedCommunicationType: json['suggestedCommunicationType'] ?? 'slack',
      suggestedSeverity: json['suggestedSeverity'] ?? 'medium',
      keyTermHighlight: List<String>.from(json['keyTermHighlight'] ?? []),
      alternativeVersions: (json['alternativeVersions'] as List<dynamic>?)
              ?.map((e) => AlternativeVersion.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalIntent': originalIntent,
      'detectedLanguage': detectedLanguage,
      'professionalScore': professionalScore,
      'clarityScore': clarityScore,
      'toneScore': toneScore,
      'critique': critique,
      'suggestion': suggestion,
      'suggestedCommunicationType': suggestedCommunicationType,
      'suggestedSeverity': suggestedSeverity,
      'keyTermHighlight': keyTermHighlight,
      'alternativeVersions': alternativeVersions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get average score of all three metrics
  int get averageScore => ((professionalScore + clarityScore + toneScore) / 3).round();

  /// Get severity color name for UI
  String get severityColorName {
    switch (suggestedSeverity) {
      case 'critical':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'green';
      default:
        return 'gray';
    }
  }

  /// Get language display name
  String get languageDisplayName {
    switch (detectedLanguage) {
      case 'vietnamese':
        return 'Tiếng Việt';
      case 'broken_english':
        return 'Broken English';
      case 'casual_english':
        return 'Casual English';
      default:
        return detectedLanguage;
    }
  }

  /// Get communication type display name
  String get communicationTypeDisplayName {
    switch (suggestedCommunicationType) {
      case 'slack':
        return 'Slack Message';
      case 'email':
        return 'Email';
      case 'pr_comment':
        return 'PR Comment';
      case 'meeting_notes':
        return 'Meeting Notes';
      case 'documentation':
        return 'Documentation';
      default:
        return suggestedCommunicationType;
    }
  }
}

class AlternativeVersion {
  final String type;
  final String text;

  AlternativeVersion({
    required this.type,
    required this.text,
  });

  factory AlternativeVersion.fromJson(Map<String, dynamic> json) {
    return AlternativeVersion(
      type: json['type'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    };
  }

  /// Get display name for the version type
  String get displayName {
    switch (type) {
      case 'formal_email':
        return '📧 Formal Email';
      case 'quick_slack':
        return '💬 Quick Slack';
      case 'pr_comment':
        return '🔀 PR Comment';
      case 'meeting_notes':
        return '📝 Meeting Notes';
      default:
        return type;
    }
  }
}
