import '../entities/food_item.dart';

abstract class FoodRepository {
  /// Get all food items
  Future<List<FoodItem>> getAllFoodItems();

  /// Get a food item by ID
  Future<FoodItem?> getFoodItemById(String id);

  /// Search food items by name
  Future<List<FoodItem>> searchFoodItems(String query);

  /// Get favorite food items
  Future<List<FoodItem>> getFavoriteFoodItems();

  /// Add a new food item
  Future<void> addFoodItem(FoodItem foodItem);

  /// Update an existing food item
  Future<void> updateFoodItem(FoodItem foodItem);

  /// Delete a food item by ID
  Future<void> deleteFoodItem(String id);

  /// Toggle favorite status
  Future<void> toggleFavorite(String id);
}
