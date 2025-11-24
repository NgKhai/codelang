import 'package:codelang/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../business/cubit/theme_cubit.dart';
import '../../style/app_routes.dart';
import 'exercise_screen.dart';
import 'flash_card_screen.dart';
import 'test_screen.dart';
import 'test_screen_2.dart';

class ListExerciseScreen extends StatefulWidget {
  const ListExerciseScreen({super.key});

  @override
  State<ListExerciseScreen> createState() => _ListExerciseScreenState();
}

class _ListExerciseScreenState extends State<ListExerciseScreen> {

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
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlashCardScreen()),
                );
              },
              child: Text('Practice'),
            ),
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
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ExerciseScreen()),
                // );
                context.push(AppRoutes.subHome);
              },
              child: Text('Sentence Reorder Screen'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Home Screen'),
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
