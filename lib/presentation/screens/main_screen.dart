// import 'package:codelang/presentation/screens/flash_card_screen.dart';
// import 'package:codelang/presentation/screens/exercise_screen.dart';
// import 'package:codelang/presentation/screens/test_screen_2.dart';
// import 'package:codelang/style/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../business/cubit/theme_cubit.dart';
// import 'test_screen.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//
//     // Determine the current mode to display the correct icon
//     final isDarkMode = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FlashCardScreen()),
//                 );
//               },
//               child: Text('Practice'),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => TestScreen()),
//                 );
//               },
//               child: Text('Test Screen'),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => TestScreen2()),
//                 );
//               },
//               child: Text('Test Screen 2'),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ExerciseScreen()),
//                 );
//               },
//               child: Text('Sentence Reorder Screen'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // ...
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(
//                   context,
//                 ).colorScheme.primary, // Uses primary color from current theme
//                 foregroundColor: Theme.of(
//                   context,
//                 ).colorScheme.onPrimary, // Uses onPrimary color
//               ),
//               child: const Text('My Button'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.read<ThemeCubit>().toggleTheme(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../business/cubit/navigation_cubit.dart';
import '../../style/app_routes.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: MainScreenContent(child: child),
    );
  }
}

class MainScreenContent extends StatelessWidget {
  final Widget child;

  const MainScreenContent({super.key, required this.child});

  void _onTap(BuildContext context, int index) {
    context.read<NavigationCubit>().updateIndex(index);

    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.flashCard);
        break;
      case 2:
        context.go(AppRoutes.alc);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.flashCard) return 1;
    if (location == AppRoutes.alc) return 2;
    if (location == AppRoutes.profile) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<NavigationCubit, int>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B3133) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      icon: Icons.home,
                      isSelected: currentIndex == 0,
                      onTap: () => _onTap(context, 0),
                    ),
                    _NavBarItem(
                      icon: Icons.style,
                      isSelected: currentIndex == 1,
                      onTap: () => _onTap(context, 1),
                    ),
                    _NavBarItem(
                      icon: Icons.auto_awesome,
                      isSelected: currentIndex == 2,
                      onTap: () => _onTap(context, 2),
                    ),
                    _NavBarItem(
                      icon: Icons.person,
                      isSelected: currentIndex == 3,
                      onTap: () => _onTap(context, 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? primaryColor : onSurfaceVariant,
        ),
      ),
    );
  }
}