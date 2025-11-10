import 'package:codelang/data/models/flash_card.dart';
import 'package:flutter/material.dart';

class FlashCardWidget extends StatelessWidget {
  final FlashCard entry;
  const FlashCardWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // 1. Get screen dimensions using MediaQuery
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // 2. Calculate a responsive image height based on screen width
    // This maintains the responsiveness established in the previous step.
    double calculatedImageHeight = screenWidth * 0.4;
    calculatedImageHeight = calculatedImageHeight.clamp(150.0, 250.0);

    return Card(
      elevation: 4.0,
      // Added horizontal margin for spacing within the list
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content height
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
                  color: Colors.grey[200],
                  child: const Center(child: Text('Image Unavailable')),
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              // color: Colors.black,
                            ),
                          ),
                          Text(
                            entry.flashCardPartOfSpeech,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            entry.flashCardPronunciation,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Audio Icon (Speaker)
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: 28,
                      ),
                      onPressed: () {
                        print('Play audio for ${entry.flashCardWord}');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Definition (Định nghĩa)
                const Text(
                  'Định nghĩa:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.flashCardDefinition,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Example (Ví dụ)
                const Text(
                  'Ví dụ:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                  text: entry.flashCardExampleSentence,
                                ),
                                const TextSpan(text: '\n'),
                                TextSpan(
                                  text: entry.flashCardExampleTranslation,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
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
  }
}
