import 'package:codelang/style/app_colors.dart';
import 'package:codelang/style/app_router.dart';
import 'package:codelang/style/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'business/bloc/auth/auth_bloc.dart';
import 'business/bloc/auth/auth_event.dart';
import 'business/cubit/theme_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/mongo_service.dart';
import 'data/services/theme_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize MongoDB connection
  try {
    await MongoService.instance.connect();
  } catch (e) {
    print('Failed to connect to MongoDB: $e');
  }

  runApp(const MyApp());
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       // The Cubit is created here, loading the initial theme from SharedPreferences
//       create: (context) => ThemeCubit(ThemeLocalDataSource()),
//
//       // 2. Use BlocBuilder to listen for ThemeMode changes from the Cubit
//       child: BlocBuilder<ThemeCubit, ThemeMode>(
//         builder: (context, themeMode) {
//           return MaterialApp.router(
//             debugShowCheckedModeBanner: false,
//             title: 'CodeLang',
//
//             theme: AppThemes.lightTheme,
//             darkTheme: AppThemes.darkTheme,
//
//             themeMode: themeMode,
//
//             routerConfig: AppRouter.router,
//           );
//         },
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme Cubit - loading initial theme from SharedPreferences
          BlocProvider(
            create: (context) => ThemeCubit(ThemeLocalDataSource()),
          ),
          // Auth Bloc - checking authentication status
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once and reuse it
    final authBloc = context.read<AuthBloc>();
    _router = AppRouter.createRouter(authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen for ThemeMode changes from the Cubit
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'CodeLang',

          // Using your custom themes
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,

          // ThemeMode from ThemeCubit
          themeMode: themeMode,

          // Reuse the same router instance
          routerConfig: _router,
        );
      },
    );
  }
}