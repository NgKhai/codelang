// // import 'package:codelang/presentation/screens/exercise_screen.dart';
// // import 'package:codelang/presentation/screens/flash_card_screen.dart';
// // import 'package:codelang/presentation/screens/test_screen.dart';
// // import 'package:codelang/presentation/screens/unified_exercise_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import '../presentation/screens/main_screen.dart';
// // import 'app_routes.dart';
// //
// // final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
// // final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
// //
// // class AppRouter {
// //   static final GoRouter router = GoRouter(
// //     navigatorKey: _rootNavigatorKey,
// //     initialLocation: AppRoutes.home,
// //     routes: [
// //       ShellRoute(
// //         navigatorKey: _shellNavigatorKey,
// //         builder: (context, state, child) {
// //           return MainScreen(child: child);
// //         },
// //         routes: [
// //           GoRoute(
// //             path: AppRoutes.home,
// //             pageBuilder: (context, state) => NoTransitionPage(
// //               child: ListExerciseScreen(),
// //             ),
// //           ),
// //           GoRoute(
// //             path: AppRoutes.flashCard,
// //             pageBuilder: (context, state) => NoTransitionPage(
// //               child: FlashCardScreen(),
// //             ),
// //           ),
// //           GoRoute(
// //             path: AppRoutes.profile,
// //             pageBuilder: (context, state) => NoTransitionPage(
// //               child: TestScreen(),
// //             ),
// //           ),
// //         ],
// //       ),
// //       // Routes without navigation bar
// //       GoRoute(
// //         parentNavigatorKey: _rootNavigatorKey,
// //         path: AppRoutes.subHome,
// //         // builder: (context, state) => ExerciseScreen(),
// //         builder: (context, state) => UnifiedExerciseScreen(),
// //
// //       ),
// //     ],
// //   );
// // }
//
// // lib/router/app_router.dart
//
// import 'package:codelang/presentation/screens/flash_card_screen.dart';
// import 'package:codelang/presentation/screens/home_screen.dart';
// import 'package:codelang/presentation/screens/test_screen.dart';
// import 'package:codelang/presentation/screens/unified_exercise_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../presentation/screens/main_screen.dart';
// import 'app_routes.dart';
//
// final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
//
// class AppRouter {
//   static final GoRouter router = GoRouter(
//     navigatorKey: _rootNavigatorKey,
//     initialLocation: AppRoutes.home,
//     routes: [
//       ShellRoute(
//         navigatorKey: _shellNavigatorKey,
//         builder: (context, state, child) {
//           return MainScreen(child: child);
//         },
//         routes: [
//           GoRoute(
//             path: AppRoutes.home,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: HomeScreen(),
//             ),
//           ),
//           GoRoute(
//             path: AppRoutes.flashCard,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: FlashCardScreen(),
//             ),
//           ),
//           GoRoute(
//             path: AppRoutes.profile,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: TestScreen(),
//             ),
//           ),
//         ],
//       ),
//       // Routes without navigation bar
//       GoRoute(
//         parentNavigatorKey: _rootNavigatorKey,
//         path: AppRoutes.subHome,
//         builder: (context, state) {
//           // Get exerciseId from extra data
//           final extra = state.extra as Map<String, dynamic>?;
//           final exerciseId = extra?['exerciseId'] as String?;
//
//           return UnifiedExerciseScreen(exerciseSetId: exerciseId);
//         },
//       ),
//     ],
//   );
// }

// lib/style/app_router.dart

import 'dart:async';
import 'package:codelang/presentation/screens/flashcard/flash_card_screen.dart';
import 'package:codelang/presentation/screens/flashcard/flash_card_practice_screen.dart';
import 'package:codelang/presentation/screens/flashcard/flash_card_deck_screen.dart';
import 'package:codelang/presentation/screens/home/home_screen.dart';
import 'package:codelang/presentation/screens/login_screen.dart';
import 'package:codelang/presentation/screens/register_screen.dart';
import 'package:codelang/presentation/screens/home/unified_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../business/bloc/auth/auth_bloc.dart';
import '../business/bloc/auth/auth_state.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/alc/alc_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If authenticated and trying to access auth pages, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        // If not authenticated and trying to access protected pages, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        return null; // No redirect needed
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      routes: [
        // Authentication Routes
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const RegisterScreen(),
          ),
        ),

        // Protected Routes with Shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScreen(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              path: '/flash-card',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: FlashCardDeckScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: ProfileScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              path: '/alc',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: AlcScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),

        // Routes without navigation bar
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/sub-home',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final exerciseId = extra?['exerciseId'] as String?;
            return UnifiedExerciseScreen(exerciseSetId: exerciseId);
          },
        ),

        // Flash card deck routes
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/flashcards/:deckId',
          builder: (context, state) {
            final deckId = state.pathParameters['deckId'];
            final extra = state.extra as Map<String, dynamic>?;
            final deckName = extra?['deckName'] as String?;
            return FlashCardScreen(deckId: deckId, deckName: deckName);
          },
        ),
        
        // Flash card practice route
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/flashcards/:deckId/practice',
          builder: (context, state) {
            final deckId = state.pathParameters['deckId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final deckName = extra?['deckName'] as String?;
            return FlashCardPracticeScreen(deckId: deckId, deckName: deckName);
          },
        ),
      ],
    );
  }
}

// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}