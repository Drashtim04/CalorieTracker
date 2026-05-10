import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import 'food_model.dart';
import 'meal_type.dart';

part 'meal_log_model.g.dart';

/// A single meal log entry, grouping one or more [FoodModel] items
/// under a named [mealType] for a specific [dateTime].
///
/// Example:
/// ```dart
/// final log = MealLogModel(
///   id: const Uuid().v4(),
///   dateTime: DateTime.now(),
///   mealType: MealType.breakfast,
///   foods: [banana, oats],
/// );
/// ```
@HiveType(typeId: AppConstants.mealLogModelTypeId)
class MealLogModel extends HiveObject {
  MealLogModel({
    required this.id,
    required this.dateTime,
    required this.mealType,
    required this.foods,
  });

  /// Unique identifier (UUID v4)
  @HiveField(0)
  String id;

  /// Date and time when this meal was logged
  @HiveField(1)
  DateTime dateTime;

  /// One of: breakfast, lunch, dinner, snack
  @HiveField(2)
  MealType mealType;

  /// List of food items included in this meal
  @HiveField(3)
  List<FoodModel> foods;

  // ─── Computed totals ────────────────────────────────────────────────────────

  /// Total kilocalories across all foods in this meal
  double get totalCalories =>
      foods.fold(0.0, (sum, f) => sum + f.calories);

  /// Total protein in grams
  double get totalProtein =>
      foods.fold(0.0, (sum, f) => sum + f.protein);

  /// Total carbohydrates in grams
  double get totalCarbs =>
      foods.fold(0.0, (sum, f) => sum + f.carbs);

  /// Total fats in grams
  double get totalFats =>
      foods.fold(0.0, (sum, f) => sum + f.fats);

  /// Total quantity (grams) across all foods
  double get totalQuantity =>
      foods.fold(0.0, (sum, f) => sum + f.quantity);

  @override
  String toString() =>
      'MealLogModel(${mealType.label} @ $dateTime, '
      'foods: ${foods.length}, kcal: ${totalCalories.toStringAsFixed(1)})';
}
