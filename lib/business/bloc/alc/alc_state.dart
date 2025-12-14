// lib/business/bloc/alc/alc_state.dart
// Active Lingo Coach State

import 'package:equatable/equatable.dart';
import '../../../data/models/alc/alc_result.dart';

enum AlcStatus { initial, loading, success, failure }

class AlcState extends Equatable {
  final AlcStatus status;
  final AlcResult? result;
  final String? errorMessage;
  final String selectedCommunicationType;
  final String inputText;

  const AlcState({
    this.status = AlcStatus.initial,
    this.result,
    this.errorMessage,
    this.selectedCommunicationType = 'auto',
    this.inputText = '',
  });

  /// Check if currently analyzing
  bool get isLoading => status == AlcStatus.loading;

  /// Check if has result
  bool get hasResult => result != null && status == AlcStatus.success;

  /// Check if has error
  bool get hasError => errorMessage != null && status == AlcStatus.failure;

  AlcState copyWith({
    AlcStatus? status,
    AlcResult? result,
    String? errorMessage,
    String? selectedCommunicationType,
    String? inputText,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return AlcState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCommunicationType: selectedCommunicationType ?? this.selectedCommunicationType,
      inputText: inputText ?? this.inputText,
    );
  }

  @override
  List<Object?> get props => [
    status,
    result,
    errorMessage,
    selectedCommunicationType,
    inputText,
  ];
}
