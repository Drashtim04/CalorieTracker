import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';

part 'food_log_model.g.dart';

@HiveType(typeId: AppConstants.foodLogModelTypeId)
class FoodLogModel extends HiveObject {
  FoodLogModel({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.mealType,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.loggedAt,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.notes,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String foodItemId;

  @HiveField(2)
  String foodName;

  @HiveField(3)
  String mealType;

  @HiveField(4)
  double servingSize;

  @HiveField(5)
  String servingUnit;

  @HiveField(6)
  double calories;

  @HiveField(7)
  double protein;

  @HiveField(8)
  double carbohydrates;

  @HiveField(9)
  double fat;

  @HiveField(10)
  double fiber;

  @HiveField(11)
  double sugar;

  @HiveField(12)
  double sodium;

  @HiveField(13)
  DateTime loggedAt;

  @HiveField(14)
  String? notes;
}
