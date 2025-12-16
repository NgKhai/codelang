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
import '../../widgets/profile/guest_profile_section.dart';
import '../../widgets/profile/profile_dialogs.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_menu_section.dart';
import '../../widgets/profile/profile_stats_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when profile is opened
    context.read<AuthBloc>().add(AuthRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileContent();
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

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
          // Handle Guest and Offline states
          if (state is AuthGuest || state is AuthOffline) {
            return GuestProfileSection(
              isDark: isDark,
              backgroundColor: backgroundColor,
              cardColor: cardColor,
              textColor: textColor,
              state: state,
            );
          }
          
          if (state is AuthAuthenticated) {
            final user = state.user;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                ProfileHeader(isDark: isDark, user: user),

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
                              ProfileStatsSection(
                                isDark: isDark,
                                cardColor: cardColor,
                                textColor: textColor,
                                user: user,
                              ),
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
                              ProfileMenuSection.buildMenuCard(
                                cardColor: cardColor,
                                children: [
                                  ProfileMenuSection.buildMenuItem(
                                    icon: Icons.person_outline,
                                    title: 'Personal Information',
                                    subtitle: 'Change your name',
                                    textColor: textColor,
                                    onTap: () => ProfileDialogs.showChangeNameDialog(context, user.name ?? 'User'),
                                  ),
                                  ProfileMenuSection.buildDivider(isDark),
                                  ProfileMenuSection.buildMenuItem(
                                    icon: Icons.download_for_offline_outlined,
                                    title: 'Downloaded Content',
                                    subtitle: 'Manage offline downloads',
                                    textColor: textColor,
                                    onTap: () => context.push('/downloaded-content'),
                                  ),
                                  ProfileMenuSection.buildDivider(isDark),
                                  ProfileMenuSection.buildMenuItem(
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
                                    icon: Icons.notifications_outlined,
                                    title: 'Notifications',
                                    subtitle: 'Customize alerts',
                                    textColor: textColor,
                                    onTap: () {},
                                  ),
                                  ProfileMenuSection.buildDivider(isDark),
                                  ProfileMenuSection.buildMenuItem(
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
                                  onPressed: () => ProfileDialogs.showLogoutDialog(context),
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
}
