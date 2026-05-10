import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/food_model.dart';
import 'food_repository.dart';

/// Hive-backed implementation of [FoodRepository].
///
/// Uses [AppConstants.foodBox] as the Hive box key.
/// The box must be opened (and [FoodModelAdapter] registered) before
/// constructing this class — typically done in [main.dart].
class HiveFoodRepository implements FoodRepository {
  HiveFoodRepository() : _box = Hive.box<FoodModel>(AppConstants.foodBox);

  final Box<FoodModel> _box;

  // ─── Read ────────────────────────────────────────────────────────────────────

  @override
  Future<List<FoodModel>> getAll() async {
    final items = _box.values.toList();
    // Newest-first: items without createdAt go to the end
    return items;
  }

  @override
  Future<FoodModel?> getById(String id) async {
    // Hive box key == food id for O(1) lookup
    return _box.get(id);
  }

  @override
  Future<List<FoodModel>> search(String query) async {
    if (query.trim().isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _box.values
        .where((f) => f.name.toLowerCase().contains(lower))
        .toList();
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  @override
  Future<void> add(FoodModel food) async {
    if (_box.containsKey(food.id)) {
      throw ArgumentError('Food with id "${food.id}" already exists.');
    }
    await _box.put(food.id, food);
  }

  @override
  Future<void> update(FoodModel food) async {
    await _box.put(food.id, food);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await _box.clear();
  }
}
