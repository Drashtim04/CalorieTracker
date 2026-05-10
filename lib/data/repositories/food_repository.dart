import '../models/food_model.dart';

/// Contract for all food item CRUD operations.
///
/// The data layer implements this; the domain / presentation layers
/// depend only on this abstraction (Dependency Inversion).
abstract class FoodRepository {
  /// Returns every food item in the local database, newest first.
  Future<List<FoodModel>> getAll();

  /// Returns a single food item by [id], or `null` if not found.
  Future<FoodModel?> getById(String id);

  /// Case-insensitive substring search on [FoodModel.name].
  /// Returns all items if [query] is empty.
  Future<List<FoodModel>> search(String query);

  /// Persists a new [food] item. Throws [ArgumentError] if the id
  /// already exists.
  Future<void> add(FoodModel food);

  /// Replaces the stored food item that shares [food.id].
  Future<void> update(FoodModel food);

  /// Removes the food item with [id]. No-op if it doesn't exist.
  Future<void> delete(String id);

  /// Removes all food items. Use with caution.
  Future<void> deleteAll();
}
