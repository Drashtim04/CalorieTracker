import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/repositories/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepositoryImpl();
});

class GoalsNotifier extends StateNotifier<AsyncValue<NutritionGoal>> {
  GoalsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadGoal();
  }

  final GoalsRepository _repository;

  Future<void> _loadGoal() async {
    state = const AsyncValue.loading();
    try {
      final goal = await _repository.getCurrentGoal();
      state = AsyncValue.data(goal);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveGoal(NutritionGoal goal) async {
    try {
      final updated = goal.copyWith(updatedAt: DateTime.now());
      await _repository.saveGoal(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<NutritionGoal>>((ref) {
  return GoalsNotifier(ref.watch(goalsRepositoryProvider));
});

/// Convenience provider for the current goal value (with fallback to default)
final currentGoalProvider = Provider<NutritionGoal>((ref) {
  return ref.watch(goalsProvider).valueOrNull ?? NutritionGoal.defaultGoal;
});
