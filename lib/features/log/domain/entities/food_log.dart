import 'package:equatable/equatable.dart';

class FoodLog extends Equatable {
  const FoodLog({
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

  final String id;
  final String foodItemId;
  final String foodName;
  final String mealType;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final DateTime loggedAt;
  final String? notes;

  FoodLog copyWith({
    String? id,
    String? foodItemId,
    String? foodName,
    String? mealType,
    double? servingSize,
    String? servingUnit,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    DateTime? loggedAt,
    String? notes,
  }) {
    return FoodLog(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      loggedAt: loggedAt ?? this.loggedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id, foodItemId, foodName, mealType, servingSize,
        servingUnit, calories, protein, carbohydrates, fat,
        fiber, sugar, sodium, loggedAt, notes,
      ];
}
