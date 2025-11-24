import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onLeadingIconPressed;
  final bool showBackButton;
  final bool useThemeColors;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.actions,
    this.onLeadingIconPressed,
    this.showBackButton = false,
    this.useThemeColors = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? null : Colors.black.withOpacity(0.1),
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? (leadingIcon != null
          ? IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? theme.colorScheme.onSurface : Colors.white,
        ),
        onPressed: () => onLeadingIconPressed?.call(),
      )
          : null)
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: _getGradient(context, isDark),
        ),
      ),
      title: _buildTitle(context, isDark),
      actions: actions,
    );
  }

  LinearGradient _getGradient(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    if (isDark) {
      // Dark mode: subtle gradient using surface colors
      return LinearGradient(
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withOpacity(0.95),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Light mode: vibrant gradient using primary colors
      return LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final textColor = isDark ? theme.colorScheme.onSurface : Colors.white;
    final subtitleColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.7)
        : Colors.white.withOpacity(0.9);

    if (subtitle != null) {
      return Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                )
                    : null,
              ),
              child: Icon(
                leadingIcon,
                color: textColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Theme-aware action button
class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? theme.colorScheme.onSurface : Colors.white;

    return IconButton(
      icon: Icon(icon, color: iconColor),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

// Predefined AppBar styles for different screens
class AppBarStyles {
  // Practice screen style
  static CustomAppBar practice({
    VoidCallback? onFilterPressed,
    VoidCallback? onSearchPressed,
  }) {
    return CustomAppBar(
      title: 'Flashcard',
      subtitle: 'Learn with flashcards',
      leadingIcon: Icons.style,
      actions: [
        if (onFilterPressed != null)
          AppBarActionButton(
            icon: Icons.filter_list_rounded,
            tooltip: 'Filter',
            onPressed: onFilterPressed,
          ),
        if (onSearchPressed != null)
          AppBarActionButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: onSearchPressed,
          ),
      ],
    );
  }

  // Home screen style
  static CustomAppBar home({
    VoidCallback? onNotificationPressed,
    VoidCallback? onProfilePressed,
  }) {
    return CustomAppBar(
      title: 'CodeLang',
      subtitle: 'Your learning journey',
      leadingIcon: Icons.home_rounded,
      actions: [
        if (onNotificationPressed != null)
          AppBarActionButton(
            icon: Icons.notifications_rounded,
            tooltip: 'Notifications',
            onPressed: onNotificationPressed,
          ),
        if (onProfilePressed != null)
          AppBarActionButton(
            icon: Icons.person_rounded,
            tooltip: 'Profile',
            onPressed: onProfilePressed,
          ),
      ],
    );
  }

  // Vocabulary screen style
  static CustomAppBar vocabulary({
    VoidCallback? onAddPressed,
    VoidCallback? onSearchPressed,
  }) {
    return CustomAppBar(
      title: 'Vocabulary',
      subtitle: 'Your word collection',
      leadingIcon: Icons.book_rounded,
      actions: [
        if (onAddPressed != null)
          AppBarActionButton(
            icon: Icons.add_rounded,
            tooltip: 'Add Word',
            onPressed: onAddPressed,
          ),
        if (onSearchPressed != null)
          AppBarActionButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: onSearchPressed,
          ),
      ],
    );
  }

  // Progress screen style
  static CustomAppBar progress({
    VoidCallback? onCalendarPressed,
    VoidCallback? onStatsPressed,
  }) {
    return CustomAppBar(
      title: 'Progress',
      subtitle: 'Track your achievements',
      leadingIcon: Icons.trending_up_rounded,
      actions: [
        if (onCalendarPressed != null)
          AppBarActionButton(
            icon: Icons.calendar_today_rounded,
            tooltip: 'Calendar',
            onPressed: onCalendarPressed,
          ),
        if (onStatsPressed != null)
          AppBarActionButton(
            icon: Icons.bar_chart_rounded,
            tooltip: 'Statistics',
            onPressed: onStatsPressed,
          ),
      ],
    );
  }

  // Detail screen style (with back button)
  static CustomAppBar detail({
    required String title,
    String? subtitle,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      actions: actions,
    );
  }

  // Simple style (no icon, just title)
  static CustomAppBar simple({
    required String title,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
    );
  }
}
//
// // Extension for theme-aware colors
// extension ThemeHelpers on ThemeData {
//   /// Get appropriate app bar gradient colors based on theme
//   List<Color> get appBarGradientColors {
//     if (brightness == Brightness.dark) {
//       return [
//         colorScheme.surface,
//         colorScheme.surface.withOpacity(0.95),
//       ];
//     } else {
//       return [
//         colorScheme.primary,
//         colorScheme.primary.withOpacity(0.8),
//       ];
//     }
//   }
//
//   /// Get appropriate text color for app bar
//   Color get appBarTextColor {
//     return brightness == Brightness.dark
//         ? colorScheme.onSurface
//         : Colors.white;
//   }
//
//   /// Get appropriate icon color for app bar
//   Color get appBarIconColor {
//     return brightness == Brightness.dark
//         ? colorScheme.onSurface
//         : Colors.white;
//   }
// }