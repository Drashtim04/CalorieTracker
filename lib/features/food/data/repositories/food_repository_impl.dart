import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../mappers/food_item_mapper.dart';
import '../models/food_item_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl() : _box = Hive.box<FoodItemModel>(AppConstants.foodItemsBox);

  final Box<FoodItemModel> _box;

  @override
  Future<List<FoodItem>> getAllFoodItems() async {
    return _box.values.map((m) => m.toEntity()).toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
  }

  @override
  Future<FoodItem?> getFoodItemById(String id) async {
    try {
      final model = _box.values.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FoodItem>> searchFoodItems(String query) async {
    if (query.trim().isEmpty) return getAllFoodItems();
    final lower = query.toLowerCase();
    return _box.values
        .where((m) =>
            m.name.toLowerCase().contains(lower) ||
            m.category.toLowerCase().contains(lower))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<List<FoodItem>> getFavoriteFoodItems() async {
    return _box.values
        .where((m) => m.isFavorite)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> addFoodItem(FoodItem foodItem) async {
    final model = foodItem.toModel();
    await _box.put(foodItem.id, model);
  }

  @override
  Future<void> updateFoodItem(FoodItem foodItem) async {
    final model = foodItem.toModel();
    await _box.put(foodItem.id, model);
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final model = _box.get(id);
    if (model != null) {
      model.isFavorite = !model.isFavorite;
      await model.save();
    }
  }
}
