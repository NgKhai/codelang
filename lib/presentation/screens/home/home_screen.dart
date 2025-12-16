import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../business/bloc/offline/offline_bloc.dart';
import '../../../business/bloc/offline/offline_event.dart';
import '../../../business/bloc/offline/offline_state.dart';
import '../../../data/models/course/course.dart';
import '../../../data/models/exercise/unified_exercise.dart';
import '../../../data/models/offline/offline_course.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/unified_exercise_service.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_routes.dart';
import '../../../style/app_styles.dart';
import 'unified_exercise_screen.dart';

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

  /// Check if we should use offline mode (AuthOffline state OR no connectivity)
  bool _shouldUseOfflineMode(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthOffline) return true;
    return !ConnectivityService().isOnline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Matching ProfileScreen colors for consistency
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);

    final authState = context.watch<AuthBloc>().state;
    final isOfflineMode = authState is AuthOffline || !ConnectivityService().isOnline;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark, backgroundColor),

          // Offline Mode Banner
          if (isOfflineMode)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Offline Mode - Showing downloaded content',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!isOfflineMode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildDailyChallengeCard(context, isDark),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: isOfflineMode
                ? _buildOfflineCoursesList(isDark)
                : _buildOnlineCoursesList(isDark),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  /// Build courses list from downloaded offline content
  Widget _buildOfflineCoursesList(bool isDark) {
    return BlocBuilder<OfflineBloc, OfflineState>(
      builder: (context, offlineState) {
        final downloadedCourses = offlineState.downloadedCourses;

        if (downloadedCourses.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.cloud_download_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Downloaded Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download courses while online to access them offline',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return AnimationLimiter(
          child: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final offlineCourse = downloadedCourses[index];
              // Convert OfflineCourse to Course for display
              final course = _convertOfflineToCourse(offlineCourse);
              
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
            }, childCount: downloadedCourses.length),
          ),
        );
      },
    );
  }

  /// Convert OfflineCourse to Course model for display
  Course _convertOfflineToCourse(OfflineCourse offlineCourse) {
    // Parse exercises from JSON
    final exercisesData = offlineCourse.exercisesData;
    final exercises = UnifiedExerciseService.parseExercises(exercisesData);
    
    return Course(
      id: offlineCourse.id,
      name: offlineCourse.name,
      exercises: exercises,
    );
  }

  /// Build courses list from online API
  Widget _buildOnlineCoursesList(bool isDark) {
    return FutureBuilder<List<Course>>(
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
          // If online fetch fails, try to show offline content
          return _buildOfflineCoursesList(isDark);
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

        return BlocBuilder<OfflineBloc, OfflineState>(
          builder: (context, offlineState) {
            final isDownloaded = offlineState.isCourseDownloaded(course.id);
            final isDownloading = offlineState.isDownloading(course.id);
            final hasUpdate = offlineState.courseHasUpdate(course.id);

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
                    onTap: () {
                      // Check if we're in offline mode
                      final authState = context.read<AuthBloc>().state;
                      final isOfflineMode = authState is AuthOffline || !ConnectivityService().isOnline;
                      
                      if (isOfflineMode) {
                        // Navigate with pre-loaded exercises for offline mode
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UnifiedExerciseScreen(
                              exerciseSetId: course.id,
                              exercises: course.exercises,
                            ),
                          ),
                        );
                      } else {
                        // Normal online navigation
                        context.push(
                          AppRoutes.subHome,
                          extra: {'exerciseId': course.id},
                        );
                      }
                    },
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
                          // Download button
                          _buildDownloadButton(
                            context: context,
                            isDownloaded: isDownloaded,
                            isDownloading: isDownloading,
                            hasUpdate: hasUpdate,
                            onDownload: () => _downloadCourse(context, course),
                          ),
                          const SizedBox(width: 8),
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
      },
    );
  }

  Widget _buildDownloadButton({
    required BuildContext context,
    required bool isDownloaded,
    required bool isDownloading,
    required bool hasUpdate,
    required VoidCallback onDownload,
  }) {
    if (isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isDownloaded && hasUpdate) {
      return GestureDetector(
        onTap: onDownload,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sync_rounded,
            color: AppColors.warning,
            size: 20,
          ),
        ),
      );
    }

    if (isDownloaded) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.download_done_rounded,
          color: AppColors.success,
          size: 20,
        ),
      );
    }

    return GestureDetector(
      onTap: onDownload,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.download_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  void _downloadCourse(BuildContext context, Course course) {
    // Convert exercises to JSON for storage using the centralized helper
    final exercisesData = UnifiedExerciseService.serializeExercises(course.exercises);

    context.read<OfflineBloc>().add(DownloadCourse(
      courseId: course.id,
      courseName: course.name,
      exercisesData: exercisesData,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${course.name}"...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
