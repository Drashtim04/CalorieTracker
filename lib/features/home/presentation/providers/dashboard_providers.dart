import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/data_providers.dart';
import '../../../log/presentation/providers/food_log_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../../features/goals/domain/entities/nutrition_goal.dart';

// ─── Unified Dashboard State ─────────────────────────────────────────────────

/// Immutable snapshot of everything the dashboard needs to render.
class DashboardData {
  const DashboardData({
    required this.consumed,
    required this.goal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fats,
    required this.fatsGoal,
    required this.mealBreakdown,
  });

  /// Total calories consumed today.
  final double consumed;

  /// Daily calorie goal.
  final double goal;

  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbsGoal;
  final double fats;
  final double fatsGoal;

  /// Per-meal calorie map for the preview strip.
  final Map<String, double> mealBreakdown;

  // ── Derived calculations ────────────────────────────────────────────────────

  double get remaining =>
      (goal - consumed).clamp(0.0, double.infinity);

  double get overBy =>
      consumed > goal ? consumed - goal : 0;

  bool get isOverGoal => consumed > goal && goal > 0;

  double get progress =>
      goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progress * 100;

  /// Macro calorie contributions (4/4/9 kcal per gram)
  double get proteinKcal => protein * 4;
  double get carbsKcal => carbs * 4;
  double get fatsKcal => fats * 9;

  /// Share of total calories each macro contributes (0–1).
  double get proteinShare =>
      consumed > 0 ? proteinKcal / consumed : 0;
  double get carbsShare =>
      consumed > 0 ? carbsKcal / consumed : 0;
  double get fatsShare =>
      consumed > 0 ? fatsKcal / consumed : 0;

  static const DashboardData empty = DashboardData(
    consumed: 0,
    goal: 2000,
    protein: 0,
    proteinGoal: 150,
    carbs: 0,
    carbsGoal: 250,
    fats: 0,
    fatsGoal: 65,
    mealBreakdown: {},
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Merges new data-layer totals (from [dailyNutritionTotalsProvider]) with
/// goal data (from [currentGoalProvider]) into a single [DashboardData].
final dashboardDataProvider = Provider<DashboardData>((ref) {
  // New data layer: real logged meals from MealLogModel
  final newTotals = ref.watch(dailyNutritionTotalsProvider);

  // Legacy data layer: FoodLogModel logs (used by home until migration complete)
  final legacyTotals = ref.watch(dailyTotalsProvider);

  // Merge: prefer new totals when non-zero, fallback to legacy
  final calories =
      newTotals.calories > 0 ? newTotals.calories : legacyTotals.calories;
  final protein =
      newTotals.protein > 0 ? newTotals.protein : legacyTotals.protein;
  final carbs =
      newTotals.carbs > 0 ? newTotals.carbs : legacyTotals.carbohydrates;
  final fats =
      newTotals.fats > 0 ? newTotals.fats : legacyTotals.fat;

  // Goal
  final NutritionGoal goal = ref.watch(currentGoalProvider);

  // Per-meal breakdown from new layer
  final grouped = ref.watch(logsByMealTypeProvider);
  final breakdown = <String, double>{};
  for (final entry in grouped.entries) {
    final total = entry.value
        .fold<double>(0, (s, l) => s + l.totalCalories);
    if (total > 0) breakdown[entry.key.label] = total;
  }

  return DashboardData(
    consumed: calories,
    goal: goal.calorieGoal,
    protein: protein,
    proteinGoal: goal.proteinGoal,
    carbs: carbs,
    carbsGoal: goal.carbsGoal,
    fats: fats,
    fatsGoal: goal.fatGoal,
    mealBreakdown: breakdown,
  );
});

// ─── Quick-stat helper ───────────────────────────────────────────────────────

/// Burns estimate: simplified TEE using a fixed 1800 kcal base.
/// Replace with a real TDEE calculation once profile data is available.
final estimatedBurnProvider = Provider<double>((_) => 1800);

final netCaloriesProvider = Provider<double>((ref) {
  final data = ref.watch(dashboardDataProvider);
  final burn = ref.watch(estimatedBurnProvider);
  return burn - data.consumed;
});
