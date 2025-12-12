import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../data/models/course/course.dart';
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
            sliver: FutureBuilder<List<Course>>(
              future: UnifiedExerciseService.getAllCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load courses',
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final courses = snapshot.data ?? [];

                if (courses.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }

                return AnimationLimiter(
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final course = courses[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildCourseCard(
                              context,
                              course,
                              index,
                              isDark,
                            ),
                          ),
                        ),
                      );
                    }, childCount: courses.length),
                  ),
                );
              },
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Get streak info from auth state
        final hasCompletedToday = authState is AuthAuthenticated 
            ? authState.user.hasCompletedStreakToday 
            : false;
        final currentStreak = authState is AuthAuthenticated 
            ? authState.user.currentStreak 
            : 0;
        
        // Dynamic colors based on streak completion
        final streakColor = hasCompletedToday 
            ? AppColors.primary  // Use primary color for completed streak
            : Colors.grey;       // Grey when not completed
        final streakBgColor = hasCompletedToday 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.1);

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
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: streakBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: streakColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Daily Streak',
                                    style: TextStyle(
                                      color: streakColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (currentStreak > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: streakBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🔥 $currentStreak',
                                  style: TextStyle(
                                    color: streakColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasCompletedToday ? 'Great job today!' : 'Ready to Learn?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasCompletedToday 
                              ? 'Come back tomorrow to keep your streak!' 
                              : 'Complete today\'s practice to build your streak!',
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
                      color: streakBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasCompletedToday 
                          ? Icons.check_circle_rounded 
                          : Icons.local_fire_department,
                      size: 32,
                      color: streakColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Course course,
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isCompleted = authState is AuthAuthenticated
            ? authState.user.hasCourseCompleted(course.id)
            : false;

        return Hero(
          tag: 'course_${course.id}',
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
                  extra: {'exerciseId': course.id},
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
                              course.name,
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
                                '${course.exercises.length} Tasks',
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
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                      )
                    else
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
      },
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
