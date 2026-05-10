import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';

part 'nutrition_goal_model.g.dart';

@HiveType(typeId: AppConstants.nutritionGoalModelTypeId)
class NutritionGoalModel extends HiveObject {
  NutritionGoalModel({
    required this.id,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    this.updatedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  double calorieGoal;

  @HiveField(2)
  double proteinGoal;

  @HiveField(3)
  double carbsGoal;

  @HiveField(4)
  double fatGoal;

  @HiveField(5)
  double waterGoal;

  @HiveField(6)
  DateTime? updatedAt;

  // ── Biometric fields (added in v2) ────────────────────────────────────────

  /// Body weight in kilograms.
  @HiveField(7)
  double? weightKg;

  /// Height in centimetres.
  @HiveField(8)
  double? heightCm;

  /// Age in years.
  @HiveField(9)
  int? age;

  /// 'male' or 'female'
  @HiveField(10)
  String? gender;

  /// Activity multiplier key: 'sedentary' | 'light' | 'moderate' | 'active' | 'veryActive'
  @HiveField(11)
  String? activityLevel;

  /// Weight goal key: 'lose' | 'maintain' | 'gain'
  @HiveField(12)
  String? weightGoal;
}
