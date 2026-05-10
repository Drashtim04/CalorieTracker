import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';

part 'food_item_model.g.dart';

@HiveType(typeId: AppConstants.foodItemModelTypeId)
class FoodItemModel extends HiveObject {
  FoodItemModel({
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

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double servingSize;

  @HiveField(4)
  String servingUnit;

  @HiveField(5)
  double calories;

  @HiveField(6)
  double protein;

  @HiveField(7)
  double carbohydrates;

  @HiveField(8)
  double fat;

  @HiveField(9)
  double fiber;

  @HiveField(10)
  double sugar;

  @HiveField(11)
  double sodium;

  @HiveField(12)
  bool isFavorite;

  @HiveField(13)
  DateTime? createdAt;
}
