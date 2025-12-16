import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/models/flashcard/deck_statistics.dart';
import '../../../data/models/flashcard/sm2_algorithm.dart';
import '../../../data/models/flashcard/user_flashcard_progress.dart';
import '../../../data/services/flash_card_deck_service.dart';
import '../../../data/services/mongo_service.dart';
import 'flash_card_stats_event.dart';
import 'flash_card_stats_state.dart';

class FlashCardStatsBloc
    extends Bloc<FlashCardStatsEvent, FlashCardStatsState> {
  final MongoService _mongoService = MongoService.instance;
  final FlashCardDeckService _deckService = FlashCardDeckService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  FlashCardStatsBloc() : super(const FlashCardStatsState()) {
    on<LoadDeckStats>(_onLoadDeckStats);
    on<UpdateCardProgress>(_onUpdateCardProgress);
  }

  Future<String?> _getUserId() async {
    return await _secureStorage.read(key: 'userId');
  }

  Future<void> _onLoadDeckStats(
    LoadDeckStats event,
    Emitter<FlashCardStatsState> emit,
  ) async {
    emit(state.copyWith(status: FlashCardStatsStatus.loading));

    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: FlashCardStatsStatus.failure,
          errorMessage: 'User not logged in',
        ));
        return;
      }

      // Get deck to know total cards
      final deck = await _deckService.fetchDeckById(event.deckId);
      if (deck == null) {
        emit(state.copyWith(
          status: FlashCardStatsStatus.failure,
          errorMessage: 'Deck not found',
        ));
        return;
      }

      // Get aggregated stats
      final statsMap = await _mongoService.getDeckProgressStats(
        userId: userId,
        deckId: event.deckId,
        totalCards: deck.cardCount,
      );

      final stats = DeckStatistics(
        deckId: event.deckId,
        deckName: event.deckName,
        totalCards: deck.cardCount,
        newCount: statsMap['newCount'] ?? deck.cardCount,
        learningCount: statsMap['learningCount'] ?? 0,
        reviewingCount: statsMap['reviewingCount'] ?? 0,
        masteredCount: statsMap['masteredCount'] ?? 0,
        dueForReviewCount: statsMap['dueForReviewCount'] ?? 0,
      );

      emit(state.copyWith(
        status: FlashCardStatsStatus.success,
        stats: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FlashCardStatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCardProgress(
    UpdateCardProgress event,
    Emitter<FlashCardStatsState> emit,
  ) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      // Get current progress or create initial
      final existingData = await _mongoService.getCardProgress(
        userId: userId,
        flashCardId: event.flashCardId,
      );

      UserFlashCardProgress currentProgress;
      if (existingData != null) {
        currentProgress = UserFlashCardProgress.fromJson(existingData);
      } else {
        currentProgress = UserFlashCardProgress.initial(
          odUserId: userId,
          deckId: event.deckId,
          flashCardId: event.flashCardId,
        );
      }

      // Apply SM-2 algorithm
      final updatedProgress = SM2Algorithm.calculateNextReview(
        currentProgress,
        event.quality,
      );

      // Save to database
      await _mongoService.upsertCardProgress(
        userId: userId,
        deckId: event.deckId,
        flashCardId: event.flashCardId,
        progressData: updatedProgress.toJson(),
      );

      print('📚 Card ${event.flashCardId} updated: ${updatedProgress.status.name}, '
          'next review in ${updatedProgress.intervalDays} days');
    } catch (e) {
      print('Update card progress error: $e');
    }
  }


}
