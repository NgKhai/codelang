import 'package:equatable/equatable.dart';

abstract class FlashCardDeckEvent extends Equatable {
  const FlashCardDeckEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashCardDecks extends FlashCardDeckEvent {
  const LoadFlashCardDecks();
}

class RefreshFlashCardDecks extends FlashCardDeckEvent {
  const RefreshFlashCardDecks();
}
