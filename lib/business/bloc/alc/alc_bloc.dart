// lib/business/bloc/alc/alc_bloc.dart
// Active Lingo Coach Bloc

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/alc_service.dart';
import 'alc_event.dart';
import 'alc_state.dart';

class AlcBloc extends Bloc<AlcEvent, AlcState> {
  final AlcService alcService;

  AlcBloc({
    AlcService? alcService,
  })  : alcService = alcService ?? AlcService(),
        super(const AlcState()) {
    on<AnalyzeText>(_onAnalyzeText);
    on<ClearResult>(_onClearResult);
    on<UpdateCommunicationType>(_onUpdateCommunicationType);
    on<SetExampleText>(_onSetExampleText);
  }

  /// Handles text analysis
  Future<void> _onAnalyzeText(
    AnalyzeText event,
    Emitter<AlcState> emit,
  ) async {
    // Validate input
    if (event.text.trim().isEmpty) {
      emit(state.copyWith(
        status: AlcStatus.failure,
        errorMessage: 'Please enter some text to analyze',
        clearResult: true,
      ));
      return;
    }

    if (event.text.length > 5000) {
      emit(state.copyWith(
        status: AlcStatus.failure,
        errorMessage: 'Text must be 5000 characters or less',
        clearResult: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: AlcStatus.loading,
      inputText: event.text,
      clearResult: true,
      clearError: true,
    ));

    try {
      final result = await alcService.analyzeText(
        event.text,
        communicationType: event.communicationType == 'auto' 
            ? null 
            : event.communicationType,
      );

      emit(state.copyWith(
        status: AlcStatus.success,
        result: result,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AlcStatus.failure,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
        clearResult: true,
      ));
    }
  }

  /// Handles clearing the result
  void _onClearResult(
    ClearResult event,
    Emitter<AlcState> emit,
  ) {
    emit(state.copyWith(
      status: AlcStatus.initial,
      inputText: '',
      clearResult: true,
      clearError: true,
    ));
  }

  /// Handles updating communication type
  void _onUpdateCommunicationType(
    UpdateCommunicationType event,
    Emitter<AlcState> emit,
  ) {
    emit(state.copyWith(
      selectedCommunicationType: event.communicationType,
    ));
  }

  /// Handles setting example text
  void _onSetExampleText(
    SetExampleText event,
    Emitter<AlcState> emit,
  ) {
    emit(state.copyWith(
      inputText: event.text,
    ));
  }
}
