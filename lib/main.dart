import 'package:codelang/presentation/screens/main_screen.dart';
import 'package:codelang/style/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'business/cubit/theme_cubit.dart';
import 'data/services/theme_service.dart';

void main() {
  runApp(const CodeLangApp());
}

class CodeLangApp extends StatelessWidget {
  const CodeLangApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the ThemeCubit and provide it to the widget tree
    return BlocProvider(
      // The Cubit is created here, loading the initial theme from SharedPreferences
      create: (context) => ThemeCubit(ThemeLocalDataSource()),

      // 2. Use BlocBuilder to listen for ThemeMode changes from the Cubit
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CodeLang',

            // Assign the themes defined in app_themes.dart
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,

            // Control the current theme using the state variable (themeMode) from the Cubit
            themeMode: themeMode,

            // ScannerPage now gets the Cubit's context automatically
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: MainScreen(),
    );
  }
}
