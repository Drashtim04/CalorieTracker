import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Legacy feature adapters
import 'features/food/data/models/food_item_model.dart';
import 'features/log/data/models/food_log_model.dart';
import 'features/goals/data/models/nutrition_goal_model.dart';

// Core data layer adapters
import 'data/models/food_model.dart';
import 'data/models/meal_log_model.dart';
import 'data/models/meal_type.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Hive ──────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Initialize dotenv ────────────────────────────────────────────────────
  await dotenv.load(fileName: ".env");

  // ── Register all Hive Adapters ───────────────────────────────────────────
  // Legacy feature models (typeIds 0–2)
  Hive.registerAdapter(FoodItemModelAdapter());
  Hive.registerAdapter(FoodLogModelAdapter());
  Hive.registerAdapter(NutritionGoalModelAdapter());

  // Core data models (typeIds 3–5)
  // MealType (5) must be registered before MealLogModel (4) because
  // MealLogModel embeds it.
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(FoodModelAdapter());
  Hive.registerAdapter(MealLogModelAdapter());

  // ── Open all Hive Boxes ───────────────────────────────────────────────────
  await Future.wait([
    // Legacy feature boxes
    Hive.openBox<FoodItemModel>(AppConstants.foodItemsBox),
    Hive.openBox<FoodLogModel>(AppConstants.foodLogBox),
    Hive.openBox<NutritionGoalModel>(AppConstants.goalsBox),
    // Core data boxes
    Hive.openBox<FoodModel>(AppConstants.foodBox),
    Hive.openBox<MealLogModel>(AppConstants.mealLogBox),
    // Settings box
    Hive.openBox(AppConstants.settingsBox),
  ]);

  runApp(
    const ProviderScope(
      child: CalorieTrackerApp(),
    ),
  );
}

class CalorieTrackerApp extends ConsumerWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
