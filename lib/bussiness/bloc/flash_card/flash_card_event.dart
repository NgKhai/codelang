import 'package:equatable/equatable.dart';

abstract class FlashCardEvent extends Equatable {
  const FlashCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashCards extends FlashCardEvent {
  const LoadFlashCards();
}

class LoadMoreFlashCards extends FlashCardEvent {
  const LoadMoreFlashCards();
}

class RefreshFlashCards extends FlashCardEvent {
  const RefreshFlashCards();
}