import 'package:codelang/style/app_router.dart';
import 'package:codelang/style/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'business/bloc/auth/auth_bloc.dart';
import 'business/bloc/auth/auth_event.dart';
import 'business/bloc/offline/offline_bloc.dart';
import 'business/bloc/offline/offline_event.dart';
import 'business/cubit/theme_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/offline_storage_service.dart';
import 'data/services/theme_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await OfflineStorageService.initialize();

  // Initialize connectivity monitoring
  await ConnectivityService().initialize();

  runApp(const MyApp());
}

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
          // Offline Bloc - managing downloaded content
          BlocProvider(
            create: (context) => OfflineBloc()..add(const LoadDownloadedContent()),
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