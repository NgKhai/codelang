import 'package:codelang/data/models/flash_card.dart';
import 'package:codelang/data/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/bloc/flash_card/flash_card_bloc.dart';
import '../../business/bloc/flash_card/flash_card_event.dart';
import '../../business/bloc/flash_card/flash_card_state.dart';

class FlashCardWidget extends StatelessWidget {
  final FlashCard entry;

  const FlashCardWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get screen dimensions using MediaQuery
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Calculate a responsive image height based on screen width
    double calculatedImageHeight = screenWidth * 0.4;
    calculatedImageHeight = calculatedImageHeight.clamp(150.0, 250.0);

    return BlocBuilder<FlashCardBloc, FlashCardState>(
      buildWhen: (previous, current) {
        // Only rebuild if the speaking state changed for this specific word
        return previous.isSpeaking != current.isSpeaking &&
            (current.speakingWord == entry.flashCardWord ||
                previous.speakingWord == entry.flashCardWord);
      },
      builder: (context, state) {
        final isSpeaking =
            state.isSpeaking && state.speakingWord == entry.flashCardWord;

        return Card(
          elevation: isDark ? 0 : 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: isDark
                ? BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))
                : BorderSide.none,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Image Section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  entry.flashCardImageUrl,
                  height: calculatedImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: calculatedImageHeight,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image Unavailable',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Padding for the text content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Word, Part of Speech, Pronunciation, and Audio Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              Text(
                                entry.flashCardWord,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                entry.flashCardPartOfSpeech,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                entry.flashCardPronunciation,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Audio Icon (Speaker) with animation
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSpeaking
                                  ? Icons.volume_up
                                  : Icons.volume_up_outlined,
                              key: ValueKey(isSpeaking),
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          onPressed: isSpeaking
                              ? null
                              : () {
                                  context.read<FlashCardBloc>().add(
                                    SpeakFlashCardWord(
                                      word: entry.flashCardWord,
                                      language: TtsLanguages.englishUS,
                                      speechRate: TtsSpeechRates.normal,
                                    ),
                                  );
                                },
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          tooltip: 'Pronounce word',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. Definition (Định nghĩa)
                    Text(
                      'Định nghĩa:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.flashCardDefinition,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. Example (Ví dụ)
                    Text(
                      'Ví dụ:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Example Sentence and Translation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(
                                    context,
                                  ).style.copyWith(fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: entry.flashCardExampleSentence,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const TextSpan(text: '\n'),
                                    TextSpan(
                                      text: entry.flashCardExampleTranslation,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
