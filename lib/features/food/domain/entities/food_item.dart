import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.isFavorite = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final bool isFavorite;
  final DateTime? createdAt;

  /// Calculate nutrition scaled to a given serving size
  FoodItem scaledTo(double newServingSize) {
    if (servingSize == 0) return this;
    final factor = newServingSize / servingSize;
    return FoodItem(
      id: id,
      name: name,
      category: category,
      servingSize: newServingSize,
      servingUnit: servingUnit,
      calories: calories * factor,
      protein: protein * factor,
      carbohydrates: carbohydrates * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? category,
    double? servingSize,
    String? servingUnit,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, name, category, servingSize, servingUnit,
        calories, protein, carbohydrates, fat, fiber,
        sugar, sodium, isFavorite, createdAt,
      ];
}
