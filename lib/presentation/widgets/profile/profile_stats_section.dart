import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';

class ProfileStatsSection extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final dynamic user;

  const ProfileStatsSection({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final hasCompletedToday = user.hasCompletedStreakToday;
    final streakColor = hasCompletedToday ? AppColors.primary : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: '${user.currentStreak}',
            label: 'Streaks',
            icon: Icons.local_fire_department,
            color: streakColor,
            textColor: textColor,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
          _buildStatItem(
            value: '${user.completedCourseIds.length}',
            label: 'Courses',
            icon: Icons.book,
            color: AppColors.accent,
            textColor: textColor,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
          _buildStatItem(
            value: '${user.learnedWordsCount}',
            label: 'Words Learned',
            icon: Icons.school_rounded,
            color: AppColors.warning,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
