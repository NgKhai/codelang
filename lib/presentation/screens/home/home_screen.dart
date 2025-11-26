import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../data/models/exercise/exercise.dart';
import '../../../data/services/unified_exercise_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_routes.dart';
import '../../../style/app_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = UnifiedExerciseService.getAllExerciseSets();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Matching ProfileScreen colors for consistency
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark, backgroundColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildDailyChallengeCard(context, isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: exercises.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final exercise = exercises[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildExerciseCard(
                                context,
                                exercise,
                                index,
                                isDark,
                              ),
                            ),
                          ),
                        );
                      }, childCount: exercises.length),
                    ),
                  ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    bool isDark,
    Color backgroundColor,
  ) {
    return SliverAppBar(
      expandedHeight: 50.0,
      floating: true,
      pinned: true,
      stretch: true,
      backgroundColor: backgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [Colors.white, const Color(0xFFE0E0E0)]
                : [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'CodeLang',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        background: Container(color: backgroundColor),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.subHome, extra: {'exerciseId': 'random'}),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Daily Challenge',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to Learn?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a random practice session now!',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    int index,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.warning,
      AppColors.success,
      const Color(0xFF9B59B6),
      const Color(0xFFE91E63),
    ];
    final color = colors[index % colors.length];

    final icons = [
      Icons.code_rounded,
      Icons.data_object_rounded,
      Icons.functions_rounded,
      Icons.schema_rounded,
      Icons.architecture_rounded,
      Icons.memory_rounded,
    ];
    final icon = icons[index % icons.length];

    return Hero(
      tag: 'exercise_${exercise.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push(
              AppRoutes.subHome,
              extra: {'exerciseId': exercise.id},
            ),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_rounded,
                              size: 16,
                              color: textColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.exercises.length} Tasks',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildDifficultyBadge(index),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: textColor.withOpacity(0.3),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(int index) {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    final level = levels[index % levels.length];
    Color color;

    switch (level) {
      case 'Beginner':
        color = AppColors.success;
        break;
      case 'Intermediate':
        color = AppColors.warning;
        break;
      case 'Advanced':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Exercises Available',
            style: AppStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new exercises',
            style: AppStyles.bodyText.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
