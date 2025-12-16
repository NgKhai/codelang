// lib/presentation/screens/alc/alc_screen.dart
// Active Lingo Coach - Main Screen with Bloc

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../business/bloc/alc/alc_bloc.dart';
import '../../../business/bloc/alc/alc_event.dart';
import '../../../business/bloc/alc/alc_state.dart';
import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_sizes.dart';
import '../../widgets/alc/alc_result_card.dart';

class AlcScreen extends StatelessWidget {
  const AlcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlcBloc(),
      child: const _AlcScreenContent(),
    );
  }
}

class _AlcScreenContent extends StatefulWidget {
  const _AlcScreenContent();

  @override
  State<_AlcScreenContent> createState() => _AlcScreenContentState();
}

class _AlcScreenContentState extends State<_AlcScreenContent> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, String>> _communicationTypes = [
    {'value': 'auto', 'label': '🎯 Auto'},
    {'value': 'slack', 'label': '💬 Slack'},
    {'value': 'email', 'label': '📧 Email'},
    {'value': 'pr_comment', 'label': '🔀 PR'},
    {'value': 'meeting_notes', 'label': '📝 Meeting'},
  ];

  final List<String> _exampleInputs = [
    "Cái API login cho user cũ nó bị lỗi 500 đó, fix đi.",
    "this code bad, need change",
    "yo this feature is lowkey broken lol",
    "button click not work, page crash always",
  ];

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _analyzeText(BuildContext context) {
    // Check if user is guest - show registration dialog
    final authState = context.read<AuthBloc>().state;
    if (!authState.canUseAlc) {
      _showRegistrationDialog(context);
      return;
    }

    final bloc = context.read<AlcBloc>();
    bloc.add(
      AnalyzeText(
        text: _textController.text,
        communicationType: bloc.state.selectedCommunicationType,
      ),
    );
    _focusNode.unfocus();
  }

  void _showRegistrationDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Register Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Lingo Coach feature requires a registered account to use.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Create an account to:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text('• Use AI-powered text improvement', style: TextStyle(fontSize: 13)),
            Text('• Save your learning progress', style: TextStyle(fontSize: 13)),
            Text('• Sync across devices', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Navigate to register screen
              context.push('/register');
            },
            child: const Text('Register Now'),
          ),
        ],
      ),
    );
  }

  void _clearInput(BuildContext context) {
    _textController.clear();
    context.read<AlcBloc>().add(const ClearResult());
  }

  void _useExample(BuildContext context, String example) {
    _textController.text = example;
    context.read<AlcBloc>().add(SetExampleText(example));
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final isGuest = authState is AuthGuest || authState is AuthOffline;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(
                left: AppSizes.p16,
                bottom: AppSizes.p16,
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🌐 ', style: TextStyle(fontSize: 18)),
                      Text(
                        'Lingo Coach',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (isGuest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Registered Only',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Transform your tech communication',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guest Banner
          if (isGuest)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Register for free to use Lingo Coach',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.p16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // Input Section
                    _buildInputSection(context, colorScheme),
                    const SizedBox(height: AppSizes.p16),

                    // Example chips
                    _buildExampleChips(context, colorScheme),
                    const SizedBox(height: AppSizes.p16),

                    // Communication Type Selector
                    _buildCommunicationTypeSelector(context, colorScheme),
                    const SizedBox(height: AppSizes.p24),

                    // Analyze Button with animation
                    BlocBuilder<AlcBloc, AlcState>(
                      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1,
                                child: child,
                              ),
                            );
                          },
                          child: state.isLoading
                              ? const SizedBox.shrink(key: ValueKey('hidden'))
                              : KeyedSubtree(
                                  key: const ValueKey('button'),
                                  child: _buildAnalyzeButton(context, colorScheme),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // Results area with animations
                    BlocBuilder<AlcBloc, AlcState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _buildResultContent(context, colorScheme, state),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText:
                  'Paste your message here...\n\nVietnamese, broken English, or casual English are all welcome! 🌐',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSizes.p16),
            ),
          ),
          // Character count and clear button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p8,
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              builder: (context, value, child) {
                final count = value.text.length;
                final isOverLimit = count > 5000;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count / 5000',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverLimit
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    if (value.text.isNotEmpty)
                      TextButton(
                        onPressed: () => _clearInput(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChips(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Try an example:',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _exampleInputs.map((example) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.p8),
                child: ActionChip(
                  label: Text(
                    example.length > 25
                        ? '${example.substring(0, 25)}...'
                        : example,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  onPressed: () => _useExample(context, example),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationTypeSelector(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📨 Communication context:',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        BlocBuilder<AlcBloc, AlcState>(
          buildWhen: (prev, curr) =>
              prev.selectedCommunicationType != curr.selectedCommunicationType,
          builder: (context, state) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _communicationTypes.map((type) {
                  final isSelected =
                      state.selectedCommunicationType == type['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.p8),
                    child: ChoiceChip(
                      label: Text(
                        type['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      side: BorderSide.none,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<AlcBloc>().add(
                            UpdateCommunicationType(type['value']!),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultContent(
    BuildContext context,
    ColorScheme colorScheme,
    AlcState state,
  ) {
    if (state.hasError) {
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: _buildErrorMessage(context, state.errorMessage!),
      );
    }
    if (state.isLoading) {
      return KeyedSubtree(
        key: const ValueKey('loading'),
        child: _buildLoadingState(context, colorScheme),
      );
    }
    if (state.hasResult) {
      return KeyedSubtree(
        key: const ValueKey('result'),
        child: AlcResultCard(result: state.result!),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('empty'),
      child: _buildEmptyState(context, colorScheme),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, ColorScheme colorScheme) {
    return FilledButton(
      onPressed: () => _analyzeText(context),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high, size: 20),
          SizedBox(width: 8),
          Text(
            'Analyze & Improve',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: AppSizes.p8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p32),
      child: Column(
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: AppSizes.p16),
          Text(
            'Analyzing your text...',
            style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            '🤖 AI is working on improvements',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            'Enter text above to get started',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            'Paste your Vietnamese, casual, or broken English message and get a professional version ✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
