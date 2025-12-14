// lib/presentation/widgets/alc/alc_result_card.dart
// Widget for displaying ALC analysis results

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/alc/alc_result.dart';
import '../../../style/app_sizes.dart';
import 'score_indicator.dart';

class AlcResultCard extends StatelessWidget {
  final AlcResult result;

  const AlcResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Section
        _buildScoresSection(context),
        const SizedBox(height: AppSizes.p16),

        // Original Intent
        _buildSectionCard(
          context: context,
          title: '🎯 Original Intent',
          content: result.originalIntent,
        ),
        const SizedBox(height: AppSizes.p8),

        // Critique (Vietnamese)
        _buildSectionCard(
          context: context,
          title: '📝 Phân Tích',
          content: result.critique,
        ),
        const SizedBox(height: AppSizes.p8),

        // Professional Suggestion
        _buildSuggestionCard(context),
        const SizedBox(height: AppSizes.p8),

        // Key Terms
        _buildKeyTermsSection(context),
        const SizedBox(height: AppSizes.p8),

        // Alternative Versions
        if (result.alternativeVersions.isNotEmpty)
          _buildAlternativesSection(context),
      ],
    );
  }

  Widget _buildScoresSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        children: [
          // Detected Language & Severity badges
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(
                context,
                result.languageDisplayName,
                colorScheme.primaryContainer,
                colorScheme.onPrimaryContainer,
              ),
              _buildBadge(
                context,
                result.suggestedSeverity.toUpperCase(),
                _getSeverityContainerColor(context, result.suggestedSeverity),
                _getSeverityColor(context, result.suggestedSeverity),
              ),
              _buildBadge(
                context,
                result.communicationTypeDisplayName,
                colorScheme.secondaryContainer,
                colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p24),
          // Score indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScoreIndicator(
                score: result.professionalScore,
                label: 'Professional',
                size: 70,
              ),
              ScoreIndicator(
                score: result.clarityScore,
                label: 'Clarity',
                size: 70,
              ),
              ScoreIndicator(
                score: result.toneScore,
                label: 'Tone',
                size: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getSeverityColor(BuildContext context, String severity) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (severity) {
      case 'critical':
        return colorScheme.error;
      case 'high':
        return colorScheme.tertiary;
      case 'medium':
        return colorScheme.secondary;
      case 'low':
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }

  Color _getSeverityContainerColor(BuildContext context, String severity) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (severity) {
      case 'critical':
        return colorScheme.errorContainer;
      case 'high':
        return colorScheme.tertiaryContainer;
      case 'medium':
        return colorScheme.secondaryContainer;
      case 'low':
        return colorScheme.primaryContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '✨ Professional Version',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.suggestion));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied to clipboard!'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                tooltip: 'Copy to clipboard',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          SelectableText(
            result.suggestion,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTermsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔑 Key Professional Terms',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            children: result.keyTermHighlight.map((term) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  term,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Alternative Versions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          ...result.alternativeVersions.map((alt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.p8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alt.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: alt.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${alt.displayName} copied!'),
                                backgroundColor: colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    SelectableText(
                      alt.text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
