import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/food_repository_impl.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/usecases/food_usecases.dart';
import '../../../../core/usecases/usecase.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepositoryImpl();
});

// ─── Use Case Providers ─────────────────────────────────────────────────────

final getAllFoodItemsProvider = Provider<GetAllFoodItems>((ref) {
  return GetAllFoodItems(ref.watch(foodRepositoryProvider));
});

final searchFoodItemsProvider = Provider<SearchFoodItems>((ref) {
  return SearchFoodItems(ref.watch(foodRepositoryProvider));
});

final getFoodItemByIdProvider = Provider<GetFoodItemById>((ref) {
  return GetFoodItemById(ref.watch(foodRepositoryProvider));
});

final addFoodItemProvider = Provider<AddFoodItem>((ref) {
  return AddFoodItem(ref.watch(foodRepositoryProvider));
});

final updateFoodItemProvider = Provider<UpdateFoodItem>((ref) {
  return UpdateFoodItem(ref.watch(foodRepositoryProvider));
});

final deleteFoodItemProvider = Provider<DeleteFoodItem>((ref) {
  return DeleteFoodItem(ref.watch(foodRepositoryProvider));
});

final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(foodRepositoryProvider));
});

// ─── State Notifiers ────────────────────────────────────────────────────────

class FoodListNotifier extends StateNotifier<AsyncValue<List<FoodItem>>> {
  FoodListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadFoodItems();
  }

  final Ref _ref;

  Future<void> loadFoodItems() async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(getAllFoodItemsProvider);
      final items = await useCase(const NoParams());
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFoodItem(FoodItem item) async {
    try {
      final useCase = _ref.read(addFoodItemProvider);
      await useCase(item);
      await loadFoodItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFoodItem(FoodItem item) async {
    try {
      final useCase = _ref.read(updateFoodItemProvider);
      await useCase(item);
      await loadFoodItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      final useCase = _ref.read(deleteFoodItemProvider);
      await useCase(id);
      await loadFoodItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final useCase = _ref.read(toggleFavoriteProvider);
      await useCase(id);
      await loadFoodItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final foodListProvider =
    StateNotifierProvider<FoodListNotifier, AsyncValue<List<FoodItem>>>((ref) {
  return FoodListNotifier(ref);
});

// ─── Search Provider ─────────────────────────────────────────────────────────

final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider =
    FutureProvider.autoDispose<List<FoodItem>>((ref) async {
  final query = ref.watch(foodSearchQueryProvider);
  final useCase = ref.watch(searchFoodItemsProvider);
  return useCase(query);
});

// ─── Single food item provider ───────────────────────────────────────────────

final foodItemByIdProvider =
    FutureProvider.autoDispose.family<FoodItem?, String>((ref, id) async {
  final useCase = ref.watch(getFoodItemByIdProvider);
  return useCase(id);
});

// ─── ID Generator ────────────────────────────────────────────────────────────

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
