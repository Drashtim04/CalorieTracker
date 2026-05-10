import '../../../../core/usecases/usecase.dart';
import '../entities/food_item.dart';
import '../repositories/food_repository.dart';

class GetAllFoodItems implements UseCase<List<FoodItem>, NoParams> {
  const GetAllFoodItems(this._repository);

  final FoodRepository _repository;

  @override
  Future<List<FoodItem>> call(NoParams params) {
    return _repository.getAllFoodItems();
  }
}

class SearchFoodItems implements UseCase<List<FoodItem>, String> {
  const SearchFoodItems(this._repository);

  final FoodRepository _repository;

  @override
  Future<List<FoodItem>> call(String params) {
    return _repository.searchFoodItems(params);
  }
}

class GetFoodItemById implements UseCase<FoodItem?, String> {
  const GetFoodItemById(this._repository);

  final FoodRepository _repository;

  @override
  Future<FoodItem?> call(String params) {
    return _repository.getFoodItemById(params);
  }
}

class GetFavoriteFoodItems implements UseCase<List<FoodItem>, NoParams> {
  const GetFavoriteFoodItems(this._repository);

  final FoodRepository _repository;

  @override
  Future<List<FoodItem>> call(NoParams params) {
    return _repository.getFavoriteFoodItems();
  }
}

class AddFoodItem implements UseCase<void, FoodItem> {
  const AddFoodItem(this._repository);

  final FoodRepository _repository;

  @override
  Future<void> call(FoodItem params) {
    return _repository.addFoodItem(params);
  }
}

class UpdateFoodItem implements UseCase<void, FoodItem> {
  const UpdateFoodItem(this._repository);

  final FoodRepository _repository;

  @override
  Future<void> call(FoodItem params) {
    return _repository.updateFoodItem(params);
  }
}

class DeleteFoodItem implements UseCase<void, String> {
  const DeleteFoodItem(this._repository);

  final FoodRepository _repository;

  @override
  Future<void> call(String params) {
    return _repository.deleteFoodItem(params);
  }
}

class ToggleFavorite implements UseCase<void, String> {
  const ToggleFavorite(this._repository);

  final FoodRepository _repository;

  @override
  Future<void> call(String params) {
    return _repository.toggleFavorite(params);
  }
}
