import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/dummy/dummy_foods.dart';
import '../../../../data/models/food_model.dart';
import '../../../../data/models/meal_log_model.dart';
import '../../../../data/models/meal_type.dart';

// ─── Catalog ─────────────────────────────────────────────────────────────────

/// The full static food catalog (55 items).
final foodCatalogProvider = Provider<List<FoodModel>>(
  (_) => DummyFoods.all,
);

// ─── Search ──────────────────────────────────────────────────────────────────

/// Text typed in the search bar. Empty string = no filter.
final searchQueryProvider = StateProvider.autoDispose<String>((_) => '');

/// Selected category chip. 'All' = no category filter.
final selectedCategoryProvider =
    StateProvider.autoDispose<String>((_) => 'All');

/// Real-time filtered food list derived from query + category.
/// Updates synchronously (no async needed — catalog is in-memory).
final filteredFoodsProvider = Provider.autoDispose<List<FoodModel>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final catalog = ref.watch(foodCatalogProvider);

  return catalog.where((food) {
    final matchesQuery =
        query.isEmpty || food.name.toLowerCase().contains(query);
    final matchesCategory =
        category == 'All' || DummyFoods.categoryFor(food) == category;
    return matchesQuery && matchesCategory;
  }).toList();
});

// ─── Meal Cart ───────────────────────────────────────────────────────────────

/// Represents a single entry in the cart with its adjusted quantity.
class CartEntry {
  const CartEntry({required this.food, required this.quantity});

  /// The food item at its base (per-100 g) values.
  final FoodModel food;

  /// User-adjusted quantity in grams (or the food's native unit).
  final double quantity;

  /// Returns [food] scaled to [quantity].
  FoodModel get scaled => food.scaledTo(quantity);

  CartEntry copyWith({FoodModel? food, double? quantity}) =>
      CartEntry(food: food ?? this.food, quantity: quantity ?? this.quantity);
}

/// State held by [MealCartNotifier].
class MealCartState {
  const MealCartState({
    this.entries = const [],
    this.mealType = MealType.breakfast,
  });

  final List<CartEntry> entries;
  final MealType mealType;

  // ── Computed totals ─────────────────────────────────────────────────────────
  double get totalCalories =>
      entries.fold(0.0, (s, e) => s + e.scaled.calories);
  double get totalProtein =>
      entries.fold(0.0, (s, e) => s + e.scaled.protein);
  double get totalCarbs =>
      entries.fold(0.0, (s, e) => s + e.scaled.carbs);
  double get totalFats =>
      entries.fold(0.0, (s, e) => s + e.scaled.fats);

  bool get isEmpty => entries.isEmpty;
  int get count => entries.length;

  MealCartState copyWith({
    List<CartEntry>? entries,
    MealType? mealType,
  }) =>
      MealCartState(
        entries: entries ?? this.entries,
        mealType: mealType ?? this.mealType,
      );
}

/// Manages the "cart" of food items the user is building into a meal.
class MealCartNotifier extends StateNotifier<MealCartState> {
  MealCartNotifier() : super(const MealCartState());

  // ── Meal type ───────────────────────────────────────────────────────────────

  void setMealType(MealType type) =>
      state = state.copyWith(mealType: type);

  // ── Cart operations ─────────────────────────────────────────────────────────

  /// Adds [food] to the cart using [quantity] grams.
  /// If the same food id already exists, updates its quantity instead.
  void addFood(FoodModel food, double quantity) {
    final existing = state.entries.indexWhere((e) => e.food.id == food.id);
    if (existing >= 0) {
      // Update quantity of existing entry
      final updated = List<CartEntry>.from(state.entries);
      updated[existing] = updated[existing].copyWith(quantity: quantity);
      state = state.copyWith(entries: updated);
    } else {
      state = state.copyWith(
        entries: [...state.entries, CartEntry(food: food, quantity: quantity)],
      );
    }
  }

  /// Updates the quantity of the cart entry at [index].
  void updateQuantity(int index, double quantity) {
    if (index < 0 || index >= state.entries.length) return;
    final updated = List<CartEntry>.from(state.entries);
    updated[index] = updated[index].copyWith(quantity: quantity);
    state = state.copyWith(entries: updated);
  }

  /// Removes the cart entry at [index].
  void removeAt(int index) {
    final updated = List<CartEntry>.from(state.entries)..removeAt(index);
    state = state.copyWith(entries: updated);
  }

  /// Removes all entries (keeps meal type).
  void clearCart() => state = state.copyWith(entries: []);

  // ── Persist to Hive ─────────────────────────────────────────────────────────

  /// Builds a [MealLogModel] from the current cart and clears it.
  ///
  /// Does NOT write to Hive — the caller must persist the returned model
  /// via `ref.read(mealLogNotifierProvider.notifier).add(log)`.
  MealLogModel buildMeal() {
    final log = MealLogModel(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      mealType: state.mealType,
      foods: state.entries.map((e) => e.scaled).toList(),
    );
    clearCart();
    return log;
  }
}

/// Cart provider — scoped to the food search session.
/// Auto-disposes when the search screen is popped.
final mealCartProvider =
    StateNotifierProvider.autoDispose<MealCartNotifier, MealCartState>(
  (_) => MealCartNotifier(),
);

// ─── Convenience ─────────────────────────────────────────────────────────────

/// Returns true if [foodId] is already in the cart.
final isInCartProvider =
    Provider.autoDispose.family<bool, String>((ref, foodId) {
  return ref
      .watch(mealCartProvider)
      .entries
      .any((e) => e.food.id == foodId);
});
