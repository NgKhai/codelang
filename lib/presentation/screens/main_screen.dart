import 'package:codelang/presentation/screens/practice_screen.dart';
import 'package:codelang/presentation/screens/test_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bussiness/cubit/theme_cubit.dart';
import 'test_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Determine the current mode to display the correct icon
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PracticeScreen()),
              );
            }, child: Text('Practice')),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestScreen()),
                );
              },
              child: Text('Test Screen'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestScreen2()),
                );
              },
              child: Text('Test Screen 2'),
            ),
            ElevatedButton(
              onPressed: () {
                // ...
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary, // Uses primary color from current theme
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimary, // Uses onPrimary color
              ),
              child: const Text('My Button'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ThemeCubit>().toggleTheme(),
      ),
    );
  }
}
