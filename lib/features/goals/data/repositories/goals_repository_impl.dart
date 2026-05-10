import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../models/nutrition_goal_model.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl()
      : _box = Hive.box<NutritionGoalModel>(AppConstants.goalsBox);

  final Box<NutritionGoalModel> _box;
  static const String _goalKey = 'current_goal';

  @override
  Future<NutritionGoal> getCurrentGoal() async {
    final model = _box.get(_goalKey);
    if (model == null) return NutritionGoal.defaultGoal;

    return NutritionGoal(
      id:            model.id,
      calorieGoal:   model.calorieGoal,
      proteinGoal:   model.proteinGoal,
      carbsGoal:     model.carbsGoal,
      fatGoal:       model.fatGoal,
      waterGoal:     model.waterGoal,
      updatedAt:     model.updatedAt,
      weightKg:      model.weightKg,
      heightCm:      model.heightCm,
      age:           model.age,
      gender: model.gender != null
          ? (model.gender == 'male' ? Gender.male : Gender.female)
          : null,
      activityLevel: model.activityLevel != null
          ? ActivityLevel.fromString(model.activityLevel!)
          : null,
      weightGoal: model.weightGoal != null
          ? WeightGoal.fromString(model.weightGoal!)
          : null,
    );
  }

  @override
  Future<void> saveGoal(NutritionGoal goal) async {
    // Read existing model to preserve existing fields
    final existing = _box.get(_goalKey);

    final model = NutritionGoalModel(
      id:           goal.id,
      calorieGoal:  goal.calorieGoal,
      proteinGoal:  goal.proteinGoal,
      carbsGoal:    goal.carbsGoal,
      fatGoal:      goal.fatGoal,
      waterGoal:    goal.waterGoal,
      updatedAt:    goal.updatedAt,
    )
      ..weightKg      = goal.weightKg      ?? existing?.weightKg
      ..heightCm      = goal.heightCm      ?? existing?.heightCm
      ..age           = goal.age           ?? existing?.age
      ..gender        = goal.gender != null
          ? (goal.gender == Gender.male ? 'male' : 'female')
          : existing?.gender
      ..activityLevel = goal.activityLevel?.name ?? existing?.activityLevel
      ..weightGoal    = goal.weightGoal?.name    ?? existing?.weightGoal;

    await _box.put(_goalKey, model);
  }
}
