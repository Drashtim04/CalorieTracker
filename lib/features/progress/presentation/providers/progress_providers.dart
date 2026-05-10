import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/meal_log_model.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../goals/domain/entities/nutrition_goal.dart';
import '../../../goals/presentation/providers/goals_providers.dart';

// ─── View range enum ─────────────────────────────────────────────────────────

enum ProgressRange { weekly, monthly }

final progressRangeProvider =
    StateProvider<ProgressRange>((ref) => ProgressRange.weekly);

// ─── Raw logs for range ──────────────────────────────────────────────────────

/// Fetches all [MealLogModel]s for the selected [ProgressRange].
final rangeLogsProvider =
    FutureProvider.autoDispose<List<MealLogModel>>((ref) async {
  final range = ref.watch(progressRangeProvider);
  final repo = ref.watch(mealLogRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final start = range == ProgressRange.weekly
      ? today.subtract(const Duration(days: 6))
      : today.subtract(const Duration(days: 29));

  return repo.getLogsForDateRange(start, today);
});

// ─── Daily calorie points ────────────────────────────────────────────────────

/// One data point per calendar day in the range.
class DayCaloriePoint {
  const DayCaloriePoint({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.mealCount,
  });

  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final int mealCount;

  bool get hasData => calories > 0;
}

final dailyCaloriePointsProvider =
    Provider.autoDispose<List<DayCaloriePoint>>((ref) {
  final range = ref.watch(progressRangeProvider);
  final logsAsync = ref.watch(rangeLogsProvider);
  final logs = logsAsync.valueOrNull ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = range == ProgressRange.weekly ? 7 : 30;

  // Build a zeroed map for every day in range
  final dayMap = <DateTime, List<MealLogModel>>{};
  for (var i = days - 1; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    dayMap[DateTime(d.year, d.month, d.day)] = [];
  }

  // Bucket logs into their day
  for (final log in logs) {
    final key = DateTime(
        log.dateTime.year, log.dateTime.month, log.dateTime.day);
    dayMap[key]?.add(log);
  }

  return dayMap.entries.map((e) {
    final dayLogs = e.value;
    return DayCaloriePoint(
      date:      e.key,
      calories:  dayLogs.fold(0.0, (s, l) => s + l.totalCalories),
      protein:   dayLogs.fold(0.0, (s, l) => s + l.totalProtein),
      carbs:     dayLogs.fold(0.0, (s, l) => s + l.totalCarbs),
      fats:      dayLogs.fold(0.0, (s, l) => s + l.totalFats),
      mealCount: dayLogs.length,
    );
  }).toList();
});

// ─── Aggregate stats ─────────────────────────────────────────────────────────

class ProgressStats {
  const ProgressStats({
    required this.avgCalories,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.daysLogged,
    required this.daysOnTarget,
    required this.goal,
    required this.bestDay,
    required this.worstDay,
  });

  final double  avgCalories;
  final double  totalCalories;
  final double  totalProtein;
  final double  totalCarbs;
  final double  totalFats;
  final int     daysLogged;
  final int     daysOnTarget;
  final double  goal;
  final DayCaloriePoint? bestDay;
  final DayCaloriePoint? worstDay;

  double get adherencePct =>
      daysLogged > 0 ? daysOnTarget / daysLogged * 100 : 0;
}

final progressStatsProvider = Provider.autoDispose<ProgressStats>((ref) {
  final points = ref.watch(dailyCaloriePointsProvider);
  final NutritionGoal goal = ref.watch(currentGoalProvider);
  final calorieGoal = goal.calorieGoal;

  final withData = points.where((p) => p.hasData).toList();
  if (withData.isEmpty) {
    return ProgressStats(
      avgCalories: 0,
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFats: 0,
      daysLogged: 0,
      daysOnTarget: 0,
      goal: calorieGoal,
      bestDay: null,
      worstDay: null,
    );
  }

  final total = withData.fold(0.0, (s, p) => s + p.calories);
  final avg = total / withData.length;

  // On-target: within ±10 % of goal
  final onTarget = withData
      .where((p) => (p.calories - calorieGoal).abs() / calorieGoal <= 0.1)
      .length;

  final sorted = [...withData]..sort((a, b) => a.calories.compareTo(b.calories));

  return ProgressStats(
    avgCalories:  avg,
    totalCalories: total,
    totalProtein:  withData.fold(0.0, (s, p) => s + p.protein),
    totalCarbs:    withData.fold(0.0, (s, p) => s + p.carbs),
    totalFats:     withData.fold(0.0, (s, p) => s + p.fats),
    daysLogged:    withData.length,
    daysOnTarget:  onTarget,
    goal:          calorieGoal,
    bestDay:       sorted.last,
    worstDay:      sorted.first,
  );
});

// ─── Weight log (stub — ready for Hive persistence) ─────────────────────────

class WeightEntry {
  const WeightEntry({required this.date, required this.kg});
  final DateTime date;
  final double kg;
}

/// In-memory weight log — replace with Hive persistence when ready.
final weightLogProvider = StateProvider<List<WeightEntry>>((ref) => []);

final weightTrendProvider = Provider<List<WeightEntry>>((ref) {
  final range = ref.watch(progressRangeProvider);
  final all = ref.watch(weightLogProvider);
  final now = DateTime.now();
  final cutoff = range == ProgressRange.weekly
      ? now.subtract(const Duration(days: 7))
      : now.subtract(const Duration(days: 30));
  return all.where((e) => e.date.isAfter(cutoff)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});
