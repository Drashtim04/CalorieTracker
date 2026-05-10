import '../../domain/entities/food_log.dart';
import '../models/food_log_model.dart';

extension FoodLogModelMapper on FoodLogModel {
  FoodLog toEntity() {
    return FoodLog(
      id: id,
      foodItemId: foodItemId,
      foodName: foodName,
      mealType: mealType,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      loggedAt: loggedAt,
      notes: notes,
    );
  }
}

extension FoodLogMapper on FoodLog {
  FoodLogModel toModel() {
    return FoodLogModel(
      id: id,
      foodItemId: foodItemId,
      foodName: foodName,
      mealType: mealType,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      loggedAt: loggedAt,
      notes: notes,
    );
  }
}
