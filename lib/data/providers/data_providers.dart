import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/food_model.dart';
import '../models/meal_log_model.dart';
import '../models/meal_type.dart';
import '../repositories/food_repository.dart';
import '../repositories/hive_food_repository.dart';
import '../repositories/hive_meal_log_repository.dart';
import '../repositories/meal_log_repository.dart';

// ─── UUID Provider ───────────────────────────────────────────────────────────

/// Shared UUID generator — use `ref.read(uuidProvider).v4()` to generate IDs.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ─── Repository Providers ────────────────────────────────────────────────────

/// Provides [FoodRepository] backed by Hive.
final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => HiveFoodRepository(),
);

/// Provides [MealLogRepository] backed by Hive.
final mealLogRepositoryProvider = Provider<MealLogRepository>(
  (ref) => HiveMealLogRepository(),
);

// ─── Food State ──────────────────────────────────────────────────────────────

/// Manages the in-memory food list and delegates persistence to [FoodRepository].
class FoodNotifier extends StateNotifier<AsyncValue<List<FoodModel>>> {
  FoodNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  final FoodRepository _repo;

  /// Loads all food items from the database.
  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Adds [food] and refreshes the list.
  Future<void> add(FoodModel food) async {
    try {
      await _repo.add(food);
      await loadAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates [food] and refreshes the list.
  Future<void> update(FoodModel food) async {
    try {
      await _repo.update(food);
      await loadAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Deletes food by [id] and refreshes the list.
  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      await loadAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Exposes an [AsyncValue<List<FoodModel>>] for all food items.
final foodNotifierProvider =
    StateNotifierProvider<FoodNotifier, AsyncValue<List<FoodModel>>>(
  (ref) => FoodNotifier(ref.watch(foodRepositoryProvider)),
);

/// Auto-disposed search results derived from a query string.
final foodSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final foodSearchResultsProvider =
    FutureProvider.autoDispose<List<FoodModel>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  return ref.watch(foodRepositoryProvider).search(query);
});

// ─── Meal Log State ──────────────────────────────────────────────────────────

/// Currently selected date for the log view. Defaults to today.
final selectedLogDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Manages meal logs for [selectedLogDateProvider].
class MealLogNotifier extends StateNotifier<AsyncValue<List<MealLogModel>>> {
  MealLogNotifier(this._repo, this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final MealLogRepository _repo;
  final Ref _ref;

  Future<void> _load() async {
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final date = _ref.read(selectedLogDateProvider);
      state = AsyncValue.data(await _repo.getLogsForDate(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Changes the active date and reloads logs.
  Future<void> changeDate(DateTime date) async {
    _ref.read(selectedLogDateProvider.notifier).state = date;
    await _load();
  }

  /// Adds a new meal log entry instantly using optimistic UI updates.
  Future<void> add(MealLogModel log) async {
    final currentLogs = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentLogs, log]..sort((a,b) => a.dateTime.compareTo(b.dateTime)));
    try {
      await _repo.add(log);
      // Background sync to ensure data integrity
      final date = _ref.read(selectedLogDateProvider);
      state = AsyncValue.data(await _repo.getLogsForDate(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _load();
    }
  }

  /// Updates an existing meal log entry instantly using optimistic UI updates.
  Future<void> update(MealLogModel log) async {
    final currentLogs = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentLogs.map((l) => l.id == log.id ? log : l).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
    );
    try {
      await _repo.update(log);
      final date = _ref.read(selectedLogDateProvider);
      state = AsyncValue.data(await _repo.getLogsForDate(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _load();
    }
  }

  /// Deletes a meal log entry by [id] instantly using optimistic UI updates.
  Future<void> delete(String id) async {
    final currentLogs = state.valueOrNull ?? [];
    state = AsyncValue.data(currentLogs.where((l) => l.id != id).toList());
    try {
      await _repo.delete(id);
      final date = _ref.read(selectedLogDateProvider);
      state = AsyncValue.data(await _repo.getLogsForDate(date));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _load();
    }
  }

  /// Forces a reload for the current selected date.
  Future<void> reload() => _load();
}

final mealLogNotifierProvider = StateNotifierProvider<MealLogNotifier,
    AsyncValue<List<MealLogModel>>>(
  (ref) {
    ref.watch(selectedLogDateProvider); // rebuild when date changes
    return MealLogNotifier(
      ref.watch(mealLogRepositoryProvider),
      ref,
    );
  },
);

// ─── Derived Providers ───────────────────────────────────────────────────────

/// Logs grouped by [MealType] for the selected date.
final logsByMealTypeProvider =
    Provider<Map<MealType, List<MealLogModel>>>((ref) {
  final logs = ref.watch(mealLogNotifierProvider).valueOrNull ?? [];
  return {
    for (final type in MealType.values)
      type: logs.where((l) => l.mealType == type).toList(),
  };
});

/// Aggregated totals for the selected date.
final dailyNutritionTotalsProvider = Provider<NutritionTotals>((ref) {
  final logs = ref.watch(mealLogNotifierProvider).valueOrNull ?? [];
  return NutritionTotals.fromLogs(logs);
});

/// Immutable snapshot of all nutritional totals for a day.
class NutritionTotals {
  const NutritionTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  factory NutritionTotals.fromLogs(List<MealLogModel> logs) {
    return NutritionTotals(
      calories: logs.fold<double>(0, (s, l) => s + l.totalCalories),
      protein:  logs.fold<double>(0, (s, l) => s + l.totalProtein),
      carbs:    logs.fold<double>(0, (s, l) => s + l.totalCarbs),
      fats:     logs.fold<double>(0, (s, l) => s + l.totalFats),
    );
  }
}
