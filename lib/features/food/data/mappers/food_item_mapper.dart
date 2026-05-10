import '../../domain/entities/food_item.dart';
import '../models/food_item_model.dart';

extension FoodItemModelMapper on FoodItemModel {
  FoodItem toEntity() {
    return FoodItem(
      id: id,
      name: name,
      category: category,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }
}

extension FoodItemMapper on FoodItem {
  FoodItemModel toModel() {
    return FoodItemModel(
      id: id,
      name: name,
      category: category,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }
}
