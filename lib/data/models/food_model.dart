import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';

part 'food_model.g.dart';

/// Core food item model used in meal logs.
///
/// [quantity] represents how many grams (or units) of this food are consumed.
/// All macro values ([calories], [protein], [carbs], [fats]) are stored
/// per the given [quantity], not per 100 g — so they represent the
/// actual amount in this serving.
@HiveType(typeId: AppConstants.foodModelTypeId)
class FoodModel extends HiveObject {
  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
  });

  /// Unique identifier (UUID v4)
  @HiveField(0)
  String id;

  /// Display name of the food item, e.g. "Banana", "Chicken Breast"
  @HiveField(1)
  String name;

  /// Kilocalories for the given [quantity]
  @HiveField(2)
  double calories;

  /// Protein in grams for the given [quantity]
  @HiveField(3)
  double protein;

  /// Carbohydrates in grams for the given [quantity]
  @HiveField(4)
  double carbs;

  /// Fats in grams for the given [quantity]
  @HiveField(5)
  double fats;

  /// Amount consumed (in grams by default, or whatever unit the user chooses)
  @HiveField(6)
  double quantity;

  /// Returns a copy with recalculated macros scaled to [newQuantity].
  /// Useful when the user changes the serving size.
  FoodModel scaledTo(double newQuantity) {
    if (quantity == 0) return this;
    final factor = newQuantity / quantity;
    return FoodModel(
      id: id,
      name: name,
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fats: fats * factor,
      quantity: newQuantity,
    );
  }

  /// Convenience: total macros in grams
  double get totalMacrosG => protein + carbs + fats;

  @override
  String toString() =>
      'FoodModel(name: $name, qty: ${quantity}g, '
      'kcal: $calories, P: ${protein}g, C: ${carbs}g, F: ${fats}g)';
}
