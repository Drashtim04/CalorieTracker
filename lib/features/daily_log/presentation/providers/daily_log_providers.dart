import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/food_model.dart';
import '../../../../data/models/meal_log_model.dart';
import '../../../../data/models/meal_type.dart';
import '../../../../data/providers/data_providers.dart';

// ─── Expand / Collapse ───────────────────────────────────────────────────────

/// Which meal sections are currently expanded. All expanded by default.
final expandedMealsProvider = StateProvider<Set<MealType>>(
  (_) => {MealType.breakfast, MealType.lunch, MealType.dinner, MealType.snack},
);

void toggleMeal(WidgetRef ref, MealType type) {
  final notifier = ref.read(expandedMealsProvider.notifier);
  final current = Set<MealType>.from(notifier.state);
  if (current.contains(type)) {
    current.remove(type);
  } else {
    current.add(type);
  }
  notifier.state = current;
}

// ─── Per-meal totals ─────────────────────────────────────────────────────────

/// Calories consumed per meal type for the selected date.
final mealCalorieTotalsProvider = Provider<Map<MealType, double>>((ref) {
  final grouped = ref.watch(logsByMealTypeProvider);
  return {
    for (final t in MealType.values)
      t: grouped[t]?.fold<double>(0, (s, l) => s + l.totalCalories) ?? 0,
  };
});

/// Number of individual food items per meal type.
final mealItemCountProvider = Provider<Map<MealType, int>>((ref) {
  final grouped = ref.watch(logsByMealTypeProvider);
  return {
    for (final t in MealType.values)
      t: grouped[t]?.fold<int>(0, (s, l) => s + l.foods.length) ?? 0,
  };
});

// ─── Flat food entries ───────────────────────────────────────────────────────

/// Flat (log, food) pairs per meal type — used by the list tiles.
class LoggedFoodEntry {
  const LoggedFoodEntry({
    required this.log,
    required this.food,
    required this.foodIndex,
  });

  /// The parent [MealLogModel] that owns this food.
  final MealLogModel log;

  /// The specific food item.
  final FoodModel food;

  /// Index of [food] within [log.foods] — used for targeted removal.
  final int foodIndex;
}

/// All food entries grouped by [MealType] as flat [LoggedFoodEntry] lists.
final flatFoodEntriesProvider =
    Provider<Map<MealType, List<LoggedFoodEntry>>>((ref) {
  final grouped = ref.watch(logsByMealTypeProvider);
  return {
    for (final t in MealType.values)
      t: [
        for (final log in grouped[t] ?? <MealLogModel>[])
          for (var i = 0; i < log.foods.length; i++)
            LoggedFoodEntry(log: log, food: log.foods[i], foodIndex: i),
      ],
  };
});

// ─── Remove helpers ──────────────────────────────────────────────────────────

/// Removes a single food from a meal log.
///
/// - If the log contains **only** this food → deletes the entire log.
/// - Otherwise → updates the log with the food removed.
Future<void> removeFoodEntry(WidgetRef ref, LoggedFoodEntry entry) async {
  final notifier = ref.read(mealLogNotifierProvider.notifier);
  final log = entry.log;

  if (log.foods.length == 1) {
    await notifier.delete(log.id);
  } else {
    final updatedFoods = [...log.foods]..removeAt(entry.foodIndex);
    final updated = MealLogModel(
      id: log.id,
      dateTime: log.dateTime,
      mealType: log.mealType,
      foods: updatedFoods,
    );
    await notifier.update(updated);
  }
}
