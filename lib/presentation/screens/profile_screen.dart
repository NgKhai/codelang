import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business/bloc/auth/auth_bloc.dart';
import '../../business/bloc/auth/auth_event.dart';
import '../../business/bloc/auth/auth_state.dart';
import '../../business/cubit/theme_cubit.dart';
import '../../style/app_colors.dart';
import '../../style/app_sizes.dart';
import '../../style/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.user;

              return CustomScrollView(
                slivers: [
                  // App Bar with gradient
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.p24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profile',
                                  style: AppStyles.headline1.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                // Theme Toggle Button
                                BlocBuilder<ThemeCubit, ThemeMode>(
                                  builder: (context, themeMode) {
                                    final isDarkMode =
                                        themeMode == ThemeMode.dark;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusLarge,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isDarkMode
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<ThemeCubit>()
                                              .toggleTheme();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Profile Avatar Section
                          Container(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.p24 * 2,
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                        image: user.photoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  user.photoUrl!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: user.photoUrl == null
                                            ? Colors.white.withOpacity(0.3)
                                            : null,
                                      ),
                                      child: user.photoUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    // Auth Provider Badge
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: user.authProvider == 'google'
                                              ? Colors.white
                                              : AppColors.accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: Icon(
                                          user.authProvider == 'google'
                                              ? Icons.g_mobiledata
                                              : Icons.email,
                                          size: 20,
                                          color: user.authProvider == 'google'
                                              ? AppColors.primary
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.p16),
                                Text(
                                  user.name ?? 'User',
                                  style: AppStyles.headline1.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.p8),
                                Text(
                                  user.email,
                                  style: AppStyles.bodyText.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Section
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p24,
                        ),
                        child: Column(
                          children: [
                            // Stats Card
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLarge,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.p24),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      icon: Icons.school,
                                      value: '24',
                                      label: 'Completed',
                                      color: AppColors.success,
                                      isDark: isDark,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.2),
                                    ),
                                    _buildStatItem(
                                      icon: Icons.local_fire_department,
                                      value: '7',
                                      label: 'Day Streak',
                                      color: AppColors.warning,
                                      isDark: isDark,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.2),
                                    ),
                                    _buildStatItem(
                                      icon: Icons.emoji_events,
                                      value: '12',
                                      label: 'Achievements',
                                      color: AppColors.accent,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.p24),

                            // Account Information Card
                            _buildSectionCard(
                              title: 'Account Information',
                              icon: Icons.person_outline,
                              cardColor: cardColor,
                              isDark: isDark,
                              children: [
                                _buildInfoTile(
                                  icon: Icons.calendar_today,
                                  label: 'Member since',
                                  value: _formatDate(user.createdAt),
                                  isDark: isDark,
                                ),
                                Divider(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.2,
                                  ),
                                  height: 32,
                                ),
                                _buildInfoTile(
                                  icon: Icons.verified_user,
                                  label: 'Account Type',
                                  value: user.authProvider == 'google'
                                      ? 'Google Account'
                                      : 'Email Account',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p16),

                            // Settings Card
                            _buildSectionCard(
                              title: 'Preferences',
                              icon: Icons.settings_outlined,
                              cardColor: cardColor,
                              isDark: isDark,
                              children: [
                                BlocBuilder<ThemeCubit, ThemeMode>(
                                  builder: (context, themeMode) {
                                    return _buildSwitchTile(
                                      icon: Icons.dark_mode,
                                      label: 'Dark Mode',
                                      value: themeMode == ThemeMode.dark,
                                      onChanged: (value) {
                                        context
                                            .read<ThemeCubit>()
                                            .toggleTheme();
                                      },
                                      isDark: isDark,
                                    );
                                  },
                                ),
                                Divider(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.2,
                                  ),
                                  height: 32,
                                ),
                                _buildActionTile(
                                  icon: Icons.notifications_outlined,
                                  label: 'Notifications',
                                  isDark: isDark,
                                  onTap: () {
                                    // TODO: Navigate to notifications settings
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p16),

                            // More Options Card
                            _buildSectionCard(
                              title: 'More',
                              icon: Icons.more_horiz,
                              cardColor: cardColor,
                              isDark: isDark,
                              children: [
                                _buildActionTile(
                                  icon: Icons.help_outline,
                                  label: 'Help & Support',
                                  isDark: isDark,
                                  onTap: () {
                                    // TODO: Navigate to help
                                  },
                                ),
                                Divider(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.2,
                                  ),
                                  height: 32,
                                ),
                                _buildActionTile(
                                  icon: Icons.info_outline,
                                  label: 'About',
                                  isDark: isDark,
                                  onTap: () {
                                    // TODO: Navigate to about
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p24),

                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showLogoutDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusLarge,
                                    ),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'Logout',
                                  style: AppStyles.buttonText,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.p24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color cardColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.p8),
                Text(
                  title,
                  style: AppStyles.subtitle.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: AppSizes.p8),
            Text(
              'Logout',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
