import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;
  bool _isInitialized = false;
  bool _isInitializing = false;

  TtsState get ttsState => _ttsState;
  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isInitialized => _isInitialized;

  /// Initialize TTS with default settings
  Future<void> initialize() async {
    // Prevent multiple simultaneous initializations
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // Set default language to English (US)
      await _flutterTts.setLanguage("en-US");

      // Set speech rate (0.0 to 1.0, default is 0.5)
      await _flutterTts.setSpeechRate(0.5);

      // Set volume (0.0 to 1.0, default is 1.0)
      await _flutterTts.setVolume(1.0);

      // Set pitch (0.5 to 2.0, default is 1.0)
      await _flutterTts.setPitch(1.0);

      // iOS specific settings
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      // Set up handlers
      _flutterTts.setStartHandler(() {
        _ttsState = TtsState.playing;
      });

      _flutterTts.setCompletionHandler(() {
        _ttsState = TtsState.stopped;
      });

      _flutterTts.setCancelHandler(() {
        _ttsState = TtsState.stopped;
      });

      _flutterTts.setPauseHandler(() {
        _ttsState = TtsState.paused;
      });

      _flutterTts.setContinueHandler(() {
        _ttsState = TtsState.continued;
      });

      _flutterTts.setErrorHandler((msg) {
        _ttsState = TtsState.stopped;
        print("TTS Error: $msg");
      });

      // Wait for engine to be ready
      await _flutterTts.awaitSpeakCompletion(true);
      
      _isInitialized = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("TTS initialization error: $e");
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Speak a single word
  Future<void> speak(String word) async {
    if (word.isEmpty) return;

    // Ensure initialized before speaking
    if (!_isInitialized) {
      await initialize();
      // Small delay to let engine stabilize
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Stop any ongoing speech
    await stop();

    try {
      await _flutterTts.speak(word);
    } catch (e) {
      print("TTS speak error: $e");
    }
  }

  /// Speak a word with custom settings
  Future<void> speakWithSettings({
    required String word,
    String? language,
    double? speechRate,
    double? pitch,
    double? volume,
  }) async {
    if (word.isEmpty) return;

    // Ensure initialized before speaking
    if (!_isInitialized) {
      await initialize();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    await stop();

    try {
      // Apply custom settings if provided
      if (language != null) await _flutterTts.setLanguage(language);
      if (speechRate != null) await _flutterTts.setSpeechRate(speechRate);
      if (pitch != null) await _flutterTts.setPitch(pitch);
      if (volume != null) await _flutterTts.setVolume(volume);

      await _flutterTts.speak(word);
    } catch (e) {
      print("TTS speakWithSettings error: $e");
    }
  }

  /// Speak a sentence or phrase
  Future<void> speakSentence(String sentence) async {
    if (sentence.isEmpty) return;

    // Ensure initialized before speaking
    if (!_isInitialized) {
      await initialize();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    await stop();
    
    try {
      await _flutterTts.speak(sentence);
    } catch (e) {
      print("TTS speakSentence error: $e");
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("TTS stop error: $e");
    }
    _ttsState = TtsState.stopped;
  }

  /// Pause current speech (if supported by platform)
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  /// Set speech rate (0.0 - 1.0, where 0.5 is normal)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Set pitch (0.5 - 2.0, where 1.0 is normal)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Get available languages
  Future<List<dynamic>> getLanguages() async {
    return await _flutterTts.getLanguages;
  }

  /// Get available voices
  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }

  /// Set voice by name
  Future<void> setVoice(Map<String, String> voice) async {
    await _flutterTts.setVoice(voice);
  }

  /// Check if a language is available
  Future<bool> isLanguageAvailable(String language) async {
    return await _flutterTts.isLanguageAvailable(language);
  }

  /// Dispose the TTS engine
  void dispose() {
    _flutterTts.stop();
  }
}

/// Predefined language codes for common languages
class TtsLanguages {
  static const String englishUS = "en-US";
  static const String englishUK = "en-GB";
  static const String englishAU = "en-AU";
  static const String vietnamese = "vi-VN";
  static const String spanish = "es-ES";
  static const String french = "fr-FR";
  static const String german = "de-DE";
  static const String italian = "it-IT";
  static const String japanese = "ja-JP";
  static const String korean = "ko-KR";
  static const String chinese = "zh-CN";
  static const String portuguese = "pt-BR";
}

/// Predefined speech rates
class TtsSpeechRates {
  static const double verySlow = 0.3;
  static const double slow = 0.4;
  static const double normal = 0.5;
  static const double fast = 0.6;
  static const double veryFast = 0.7;
}

/// Predefined pitch values
class TtsPitches {
  static const double veryLow = 0.7;
  static const double low = 0.85;
  static const double normal = 1.0;
  static const double high = 1.15;
  static const double veryHigh = 1.3;
}