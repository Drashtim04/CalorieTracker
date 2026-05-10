import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/food_log_repository_impl.dart';
import '../../domain/entities/food_log.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../../domain/usecases/food_log_usecases.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return FoodLogRepositoryImpl();
});

// ─── Use Case Providers ─────────────────────────────────────────────────────

final getLogsForDateProvider = Provider<GetLogsForDate>((ref) {
  return GetLogsForDate(ref.watch(foodLogRepositoryProvider));
});

final addFoodLogProvider = Provider<AddFoodLog>((ref) {
  return AddFoodLog(ref.watch(foodLogRepositoryProvider));
});

final deleteFoodLogProvider = Provider<DeleteFoodLog>((ref) {
  return DeleteFoodLog(ref.watch(foodLogRepositoryProvider));
});

final getLogsForDateRangeProvider = Provider<GetLogsForDateRange>((ref) {
  return GetLogsForDateRange(ref.watch(foodLogRepositoryProvider));
});

// ─── Selected Date Provider ──────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ─── Food Log Notifier ───────────────────────────────────────────────────────

class FoodLogNotifier extends StateNotifier<AsyncValue<List<FoodLog>>> {
  FoodLogNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadLogs();
  }

  final Ref _ref;

  Future<void> _loadLogs() async {
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final date = _ref.read(selectedDateProvider);
      final useCase = _ref.read(getLogsForDateProvider);
      final logs = await useCase(date);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(FoodLog log) async {
    final currentLogs = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentLogs, log]..sort((a,b) => a.loggedAt.compareTo(b.loggedAt)));
    try {
      final useCase = _ref.read(addFoodLogProvider);
      await useCase(log);
      
      final date = _ref.read(selectedDateProvider);
      final useCaseGet = _ref.read(getLogsForDateProvider);
      state = AsyncValue.data(await useCaseGet(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _loadLogs();
    }
  }

  Future<void> deleteLog(String id) async {
    final currentLogs = state.valueOrNull ?? [];
    state = AsyncValue.data(currentLogs.where((l) => l.id != id).toList());
    try {
      final useCase = _ref.read(deleteFoodLogProvider);
      await useCase(id);
      
      final date = _ref.read(selectedDateProvider);
      final useCaseGet = _ref.read(getLogsForDateProvider);
      state = AsyncValue.data(await useCaseGet(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _loadLogs();
    }
  }

  Future<void> refreshForDate(DateTime date) async {
    _ref.read(selectedDateProvider.notifier).state = date;
    await _loadLogs();
  }
}

final foodLogNotifierProvider =
    StateNotifierProvider<FoodLogNotifier, AsyncValue<List<FoodLog>>>((ref) {
  // Re-create notifier when date changes
  ref.watch(selectedDateProvider);
  return FoodLogNotifier(ref);
});

// ─── Derived Providers ───────────────────────────────────────────────────────

/// Returns logs grouped by meal type for the selected date
final logsGroupedByMealProvider =
    Provider<Map<String, List<FoodLog>>>((ref) {
  final logsAsync = ref.watch(foodLogNotifierProvider);
  return logsAsync.valueOrNull?.fold<Map<String, List<FoodLog>>>(
        {},
        (map, log) {
          map.putIfAbsent(log.mealType, () => []).add(log);
          return map;
        },
      ) ??
      {};
});

/// Total nutrition for the selected date
final dailyTotalsProvider = Provider<DailyTotals>((ref) {
  final logs = ref.watch(foodLogNotifierProvider).valueOrNull ?? [];
  return DailyTotals.fromLogs(logs);
});

class DailyTotals {
  const DailyTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  factory DailyTotals.fromLogs(List<FoodLog> logs) {
    return DailyTotals(
      calories: logs.fold(0, (s, l) => s + l.calories),
      protein: logs.fold(0, (s, l) => s + l.protein),
      carbohydrates: logs.fold(0, (s, l) => s + l.carbohydrates),
      fat: logs.fold(0, (s, l) => s + l.fat),
    );
  }
}

/// Logs for last 7 days (for progress charts)
final weeklyLogsProvider = FutureProvider<List<FoodLog>>((ref) async {
  final useCase = ref.watch(getLogsForDateRangeProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 6));
  return useCase(DateRangeParams(
    start: DateTime(start.year, start.month, start.day),
    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
  ));
});
