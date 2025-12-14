// lib/business/bloc/alc/alc_event.dart
// Active Lingo Coach Events

import 'package:equatable/equatable.dart';

abstract class AlcEvent extends Equatable {
  const AlcEvent();

  @override
  List<Object?> get props => [];
}

/// Event to analyze text
class AnalyzeText extends AlcEvent {
  final String text;
  final String? communicationType;

  const AnalyzeText({
    required this.text,
    this.communicationType,
  });

  @override
  List<Object?> get props => [text, communicationType];
}

/// Event to clear the current result
class ClearResult extends AlcEvent {
  const ClearResult();
}

/// Event to update selected communication type
class UpdateCommunicationType extends AlcEvent {
  final String communicationType;

  const UpdateCommunicationType(this.communicationType);

  @override
  List<Object?> get props => [communicationType];
}

/// Event to set example text
class SetExampleText extends AlcEvent {
  final String text;

  const SetExampleText(this.text);

  @override
  List<Object?> get props => [text];
}
