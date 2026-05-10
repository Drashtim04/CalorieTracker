import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/log/presentation/pages/food_log_page.dart';
import '../../features/log/presentation/pages/add_food_log_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/food/presentation/pages/food_search_page.dart';
import '../../features/food/presentation/pages/food_detail_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/food_search/presentation/pages/food_search_screen.dart';
import '../../features/daily_log/presentation/pages/daily_log_screen.dart';
import '../../features/profile/presentation/pages/meal_reminders_page.dart';
import '../../data/models/meal_type.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

// Route name constants
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String log = '/log';
  static const String addFoodLog = '/log/add';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String foodSearch = '/food/search';
  static const String foodSearchNew = '/food/find';  // new FoodSearchScreen
  static const String foodDetail = '/food/detail';
  static const String goals = '/goals';
  static const String mealReminders = '/reminders';
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.log,
                name: 'log',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DailyLogScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                name: 'progress',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProgressPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Routes outside the nav bar shell
      GoRoute(
        path: AppRoutes.addFoodLog,
        name: 'add-food-log',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'] ?? 'Breakfast';
          return AddFoodLogPage(mealType: mealType);
        },
      ),
      GoRoute(
        path: AppRoutes.foodSearch,
        name: 'food-search',
        builder: (context, state) => const FoodSearchPage(),
      ),
      GoRoute(
        path: AppRoutes.foodSearchNew,
        name: 'food-search-new',
        builder: (context, state) {
          final mealTypeStr = state.uri.queryParameters['mealType'];
          final mealType = mealTypeStr != null
              ? MealType.fromString(mealTypeStr)
              : null;
          return FoodSearchScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '${AppRoutes.foodDetail}/:id',
        name: 'food-detail',
        builder: (context, state) {
          final foodId = state.pathParameters['id']!;
          return FoodDetailPage(foodId: foodId);
        },
      ),
      GoRoute(
        path: AppRoutes.goals,
        name: 'goals',
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: AppRoutes.mealReminders,
        name: 'meal-reminders',
        builder: (context, state) => const MealRemindersPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
