import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/food_model.dart';
import '../models/meal_log_model.dart';
import '../models/meal_type.dart';

/// Centralizes all Hive setup for the core data layer.
///
/// Call [DatabaseInit.init] once inside [main] before [runApp].
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DatabaseInit.init();
///   runApp(const ProviderScope(child: CalorieTrackerApp()));
/// }
/// ```
class DatabaseInit {
  DatabaseInit._();

  /// Whether [init] has already been called.
  static bool _initialized = false;

  /// Initializes Hive, registers adapters, and opens all required boxes.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // ── Register adapters ──────────────────────────────────────────────────
    // Core data-layer adapters (typeIds 3–5)
    if (!Hive.isAdapterRegistered(AppConstants.foodModelTypeId)) {
      Hive.registerAdapter(FoodModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.mealLogModelTypeId)) {
      Hive.registerAdapter(MealLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.mealTypeAdapterTypeId)) {
      Hive.registerAdapter(MealTypeAdapter());
    }

    // ── Open boxes ─────────────────────────────────────────────────────────
    await Future.wait([
      Hive.openBox<FoodModel>(AppConstants.foodBox),
      Hive.openBox<MealLogModel>(AppConstants.mealLogBox),
    ]);

    _initialized = true;
  }

  /// Closes all boxes. Useful for testing teardown.
  static Future<void> dispose() async {
    await Hive.close();
    _initialized = false;
  }
}
