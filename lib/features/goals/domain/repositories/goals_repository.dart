import '../entities/nutrition_goal.dart';

abstract class GoalsRepository {
  Future<NutritionGoal> getCurrentGoal();
  Future<void> saveGoal(NutritionGoal goal);
}
