import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business/bloc/auth/auth_bloc.dart';
import '../../../business/bloc/auth/auth_event.dart';
import '../../../business/bloc/auth/auth_state.dart';
import '../../../business/cubit/theme_cubit.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_sizes.dart';
import '../../../style/app_styles.dart';
import 'profile_menu_section.dart';

class GuestProfileSection extends StatelessWidget {
  final bool isDark;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final AuthState state;

  const GuestProfileSection({
    super.key,
    required this.isDark,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = state is AuthOffline;

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
                // Gradient Background (grayed for guest)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isOffline
                          ? [Colors.grey.shade600, Colors.grey.shade500, Colors.grey.shade400]
                          : [AppColors.accent, AppColors.accent.withOpacity(0.8), AppColors.primary],
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
                // Guest Info
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
                          child: Icon(
                            isOffline ? Icons.cloud_off : Icons.person_outline,
                            size: 50,
                            color: isOffline ? Colors.grey : AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isOffline ? 'Offline Mode' : 'Guest',
                            style: AppStyles.headline1.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              isOffline ? '📴' : '👤',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOffline
                            ? 'Using downloaded content only'
                            : 'Progress will not be saved',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.p16),
                    
                    // Sign Up Prompt Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.rocket_launch, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Unlock Full Experience',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Create a free account to:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _buildBenefitItem('Save your learning progress'),
                          _buildBenefitItem('Use AI-powered Lingo Coach'),
                          _buildBenefitItem('Sync across all devices'),
                          _buildBenefitItem('Track your streaks'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/login'),
                              child: const Text(
                                'Already have an account? Sign In',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.p24),
                    
                    // Settings Section
                    Text(
                      'Settings',
                      style: AppStyles.headline1.copyWith(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    ProfileMenuSection.buildMenuCard(
                      cardColor: cardColor,
                      children: [
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            return ProfileMenuSection.buildSwitchItem(
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
                        ProfileMenuSection.buildDivider(isDark),
                        ProfileMenuSection.buildMenuItem(
                          icon: Icons.download_done,
                          title: 'Downloaded Content',
                          subtitle: 'Manage offline content',
                          textColor: textColor,
                          onTap: () => context.push('/downloaded-content'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.p24),
                    
                    // Exit Guest Mode Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.exit_to_app, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(
                              isOffline ? 'Exit Offline Mode' : 'Exit Guest Mode',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
