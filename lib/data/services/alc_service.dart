// lib/data/services/alc_service.dart
// Active Lingo Coach Service - handles API communication

import 'api_service.dart';
import '../models/alc/alc_result.dart';

class AlcService {
  final ApiService _apiService;

  AlcService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService.instance;

  /// Analyze text and get professional improvement suggestions
  Future<AlcResult> analyzeText(
    String text, {
    String? communicationType,
  }) async {
    final response = await _apiService.analyzeTextWithAlc(
      text,
      communicationType: communicationType,
    );
    return AlcResult.fromJson(response);
  }
}
