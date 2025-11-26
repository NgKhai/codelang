import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_event.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../business/cubit/theme_cubit.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_sizes.dart';
import '../../../style/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 280.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient Background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                                AppColors.accent,
                              ],
                            ),
                          ),
                        ),
                        // Decorative Circles
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // User Info
                        SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user.photoUrl != null
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: user.photoUrl == null
                                      ? Icon(Icons.person, size: 50, color: AppColors.primary)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.name ?? 'User',
                                style: AppStyles.headline1.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: AppStyles.bodyText.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // actions: [
                  //   IconButton(
                  //     icon: const Icon(Icons.settings, color: Colors.white),
                  //     onPressed: () {
                  //       // TODO: Navigate to settings
                  //     },
                  //   ),
                  // ],
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p24),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSizes.p24),
                              // Stats Section
                              _buildStatsSection(isDark, cardColor, textColor),
                              const SizedBox(height: AppSizes.p24),

                              // Menu Sections
                              Text(
                                'Account',
                                style: AppStyles.headline1.copyWith(
                                  fontSize: 20,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p16),
                              _buildMenuCard(
                                cardColor: cardColor,
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.person_outline,
                                    title: 'Personal Information',
                                    subtitle: 'Change your name',
                                    textColor: textColor,
                                    onTap: () => _showChangeNameDialog(context, user.name ?? 'User'),
                                  ),
                                  _buildDivider(isDark),
                                  _buildMenuItem(
                                    icon: Icons.security,
                                    title: 'Security',
                                    subtitle: 'Password & 2FA',
                                    textColor: textColor,
                                    onTap: () {},
                                  ),
                                  _buildDivider(isDark),
                                  _buildMenuItem(
                                    icon: Icons.payment,
                                    title: 'Payments',
                                    subtitle: 'Manage subscriptions',
                                    textColor: textColor,
                                    onTap: () {},
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSizes.p24),
                              Text(
                                'Preferences',
                                style: AppStyles.headline1.copyWith(
                                  fontSize: 20,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p16),
                              _buildMenuCard(
                                cardColor: cardColor,
                                children: [
                                  BlocBuilder<ThemeCubit, ThemeMode>(
                                    builder: (context, themeMode) {
                                      return _buildSwitchItem(
                                        icon: Icons.dark_mode_outlined,
                                        title: 'Dark Mode',
                                        value: themeMode == ThemeMode.dark,
                                        textColor: textColor,
                                        onChanged: (value) {
                                          context.read<ThemeCubit>().toggleTheme();
                                        },
                                      );
                                    },
                                  ),
                                  _buildDivider(isDark),
                                  _buildMenuItem(
                                    icon: Icons.notifications_outlined,
                                    title: 'Notifications',
                                    subtitle: 'Customize alerts',
                                    textColor: textColor,
                                    onTap: () {},
                                  ),
                                  _buildDivider(isDark),
                                  _buildMenuItem(
                                    icon: Icons.language,
                                    title: 'Language',
                                    subtitle: 'English (US)',
                                    textColor: textColor,
                                    onTap: () {},
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSizes.p24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showLogoutDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error.withOpacity(0.1),
                                    foregroundColor: AppColors.error,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
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
    );
  }

  Widget _buildStatsSection(bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: '24',
            label: 'Courses',
            icon: Icons.book,
            color: AppColors.primary,
            textColor: textColor,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
          _buildStatItem(
            value: '12',
            label: 'Certificates',
            icon: Icons.workspace_premium,
            color: AppColors.accent,
            textColor: textColor,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
          _buildStatItem(
            value: '145',
            label: 'Points',
            icon: Icons.star,
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

  Widget _buildMenuCard({
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white10 : Colors.grey.shade100,
    );
  }

  void _showChangeNameDialog(BuildContext context, String currentName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: currentName);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Update Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your new name below',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Input Field
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      controller: nameController,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. John Doe',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => nameController.clear(),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  
                  // Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newName = nameController.text.trim();
                              if (newName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Name cannot be empty'),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                                return;
                              }
                              
                              if (newName == currentName) {
                                Navigator.of(context).pop();
                                return;
                              }

                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(AuthUpdateNameRequested(newName: newName));
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text('Name updated successfully!'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
