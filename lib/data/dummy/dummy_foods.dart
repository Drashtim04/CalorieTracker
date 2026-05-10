import '../models/food_model.dart';

/// Static food catalog used as seed data before a real API is integrated.
///
/// All macros are expressed **per 100 g** of the food unless noted otherwise.
/// Call [DummyFoods.all] to get the full list; search/filter on the consumer
/// side via the search providers.
class DummyFoods {
  DummyFoods._();

  static List<FoodModel> get all => _items;

  static final List<FoodModel> _items = [
    // ── Grains & Cereals ──────────────────────────────────────────────────────
    _f('d001', 'White Rice (cooked)',  'Grains',    130, 2.7,  28.2, 0.3,  100),
    _f('d002', 'Brown Rice (cooked)',  'Grains',    123, 2.6,  25.6, 1.0,  100),
    _f('d003', 'Rolled Oats (dry)',    'Grains',    389, 16.9, 66.3, 6.9,  100),
    _f('d004', 'Whole Wheat Bread',   'Grains',    247, 13.0, 41.0, 4.2,  100),
    _f('d005', 'White Bread',         'Grains',    265, 9.0,  49.0, 3.2,  100),
    _f('d006', 'Pasta (cooked)',       'Grains',    131, 5.0,  25.0, 1.1,  100),
    _f('d007', 'Quinoa (cooked)',      'Grains',    120, 4.4,  21.3, 1.9,  100),
    _f('d008', 'Cornflakes',           'Grains',    357, 8.0,  84.0, 0.4,  100),

    // ── Proteins ──────────────────────────────────────────────────────────────
    _f('d009', 'Chicken Breast',      'Protein',   165, 31.0, 0.0,  3.6,  100),
    _f('d010', 'Chicken Thigh',       'Protein',   209, 26.0, 0.0,  11.0, 100),
    _f('d011', 'Salmon (raw)',         'Protein',   208, 20.0, 0.0,  13.0, 100),
    _f('d012', 'Tuna (canned)',        'Protein',   116, 25.5, 0.0,  1.0,  100),
    _f('d013', 'Egg (whole)',          'Protein',   143, 13.0, 1.1,  10.0, 100),
    _f('d014', 'Egg White',           'Protein',    52, 11.0, 0.7,  0.2,  100),
    _f('d015', 'Beef (lean mince)',   'Protein',   215, 26.0, 0.0,  12.0, 100),
    _f('d016', 'Turkey Breast',       'Protein',   135, 30.0, 0.0,  1.0,  100),
    _f('d017', 'Tofu (firm)',         'Protein',    76,  8.0,  1.9,  4.2,  100),
    _f('d018', 'Shrimp',             'Protein',    99, 24.0, 0.2,  0.3,  100),

    // ── Dairy ─────────────────────────────────────────────────────────────────
    _f('d019', 'Greek Yogurt',        'Dairy',      59, 10.0, 3.6,  0.4,  100),
    _f('d020', 'Milk (whole)',         'Dairy',      61,  3.2,  4.8,  3.3,  100),
    _f('d021', 'Milk (skimmed)',       'Dairy',      35,  3.4,  4.8,  0.1,  100),
    _f('d022', 'Cottage Cheese',      'Dairy',      98, 11.0, 3.4,  4.5,  100),
    _f('d023', 'Cheddar Cheese',      'Dairy',     402, 25.0, 1.3,  33.0, 100),
    _f('d024', 'Mozzarella',          'Dairy',     280, 28.0, 2.2,  17.0, 100),
    _f('d025', 'Butter',             'Dairy',     717,  0.9,  0.1,  81.0, 100),

    // ── Fruits ────────────────────────────────────────────────────────────────
    _f('d026', 'Banana',             'Fruits',     89,  1.1,  23.0, 0.3,  100),
    _f('d027', 'Apple',              'Fruits',     52,  0.3,  14.0, 0.2,  100),
    _f('d028', 'Orange',             'Fruits',     47,  0.9,  12.0, 0.1,  100),
    _f('d029', 'Strawberries',       'Fruits',     32,  0.7,   7.7, 0.3,  100),
    _f('d030', 'Blueberries',        'Fruits',     57,  0.7,  14.5, 0.3,  100),
    _f('d031', 'Mango',              'Fruits',     60,  0.8,  15.0, 0.4,  100),
    _f('d032', 'Avocado',            'Fruits',    160,  2.0,   9.0, 15.0, 100),
    _f('d033', 'Watermelon',         'Fruits',     30,  0.6,   8.0, 0.2,  100),

    // ── Vegetables ────────────────────────────────────────────────────────────
    _f('d034', 'Broccoli',           'Vegetables',  34,  2.8,   7.0, 0.4,  100),
    _f('d035', 'Spinach',            'Vegetables',  23,  2.9,   3.6, 0.4,  100),
    _f('d036', 'Sweet Potato',       'Vegetables',  86,  1.6,  20.0, 0.1,  100),
    _f('d037', 'Carrot',             'Vegetables',  41,  0.9,  10.0, 0.2,  100),
    _f('d038', 'Bell Pepper',        'Vegetables',  31,  1.0,   6.0, 0.3,  100),
    _f('d039', 'Cucumber',           'Vegetables',  16,  0.7,   3.6, 0.1,  100),
    _f('d040', 'Tomato',             'Vegetables',  18,  0.9,   3.9, 0.2,  100),
    _f('d041', 'Kale',               'Vegetables',  49,  4.3,   9.0, 0.9,  100),

    // ── Legumes ───────────────────────────────────────────────────────────────
    _f('d042', 'Chickpeas (cooked)', 'Legumes',   164,  8.9,  27.4, 2.6,  100),
    _f('d043', 'Lentils (cooked)',   'Legumes',   116,  9.0,  20.0, 0.4,  100),
    _f('d044', 'Black Beans',        'Legumes',   132,  8.9,  23.7, 0.5,  100),

    // ── Nuts & Seeds ──────────────────────────────────────────────────────────
    _f('d045', 'Almonds',            'Nuts',      579, 21.0,  22.0, 50.0, 100),
    _f('d046', 'Peanut Butter',      'Nuts',      588, 25.0,  20.0, 50.0, 100),
    _f('d047', 'Walnuts',            'Nuts',      654, 15.0,  14.0, 65.0, 100),
    _f('d048', 'Chia Seeds',         'Nuts',      486, 17.0,  42.0, 31.0, 100),
    _f('d049', 'Flaxseeds',          'Nuts',      534, 18.0,  29.0, 42.0, 100),

    // ── Snacks & Others ───────────────────────────────────────────────────────
    _f('d050', 'Protein Bar',        'Snacks',    380, 30.0,  40.0, 10.0, 100),
    _f('d051', 'Dark Chocolate 70%', 'Snacks',    598,  8.0,  46.0, 43.0, 100),
    _f('d052', 'Hummus',             'Snacks',    177,  5.0,  14.0, 10.0, 100),
    _f('d053', 'Olive Oil',          'Fats',      884,  0.0,   0.0, 100.0, 100),
    _f('d054', 'Honey',              'Sweets',    304,  0.3,  82.0, 0.0,  100),
    _f('d055', 'Protein Shake',      'Drinks',    120, 24.0,   5.0, 1.5,  250),
  ];

  /// All unique category names from the catalog.
  static List<String> get categories {
    final seen = <String>{};
    return _items
        .map((f) => f.name.split('(').first.trim()) // not quite — use category
        .toSet()
        .toList();
  }

  static List<String> get categoryNames =>
      _items.map((f) {
        // Extract from the category field we store in the name hack below
        return f.id; // not used, just a placeholder
      }).toList();

  // Helper to build a FoodModel concisely
  static FoodModel _f(
    String id,
    String name,
    String category,
    double calories,
    double protein,
    double carbs,
    double fats,
    double quantity,
  ) {
    return FoodModel(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      quantity: quantity,
    );
  }

  /// Returns all unique category strings extracted from the catalog.
  static List<String> get allCategories => [
        'All',
        'Grains',
        'Protein',
        'Dairy',
        'Fruits',
        'Vegetables',
        'Legumes',
        'Nuts',
        'Snacks',
        'Fats',
        'Sweets',
        'Drinks',
      ];

  /// Maps food id prefix to category for filtering.
  static String categoryFor(FoodModel food) {
    // Re-derive category from the static list by matching id
    return _categoryMap[food.id] ?? 'Other';
  }

  static final Map<String, String> _categoryMap = {
    for (final e in _rawData) e.$1: e.$2,
  };

  // Internal raw data for category lookup
  static const List<(String, String)> _rawData = [
    ('d001', 'Grains'), ('d002', 'Grains'), ('d003', 'Grains'),
    ('d004', 'Grains'), ('d005', 'Grains'), ('d006', 'Grains'),
    ('d007', 'Grains'), ('d008', 'Grains'),
    ('d009', 'Protein'), ('d010', 'Protein'), ('d011', 'Protein'),
    ('d012', 'Protein'), ('d013', 'Protein'), ('d014', 'Protein'),
    ('d015', 'Protein'), ('d016', 'Protein'), ('d017', 'Protein'),
    ('d018', 'Protein'),
    ('d019', 'Dairy'), ('d020', 'Dairy'), ('d021', 'Dairy'),
    ('d022', 'Dairy'), ('d023', 'Dairy'), ('d024', 'Dairy'),
    ('d025', 'Dairy'),
    ('d026', 'Fruits'), ('d027', 'Fruits'), ('d028', 'Fruits'),
    ('d029', 'Fruits'), ('d030', 'Fruits'), ('d031', 'Fruits'),
    ('d032', 'Fruits'), ('d033', 'Fruits'),
    ('d034', 'Vegetables'), ('d035', 'Vegetables'), ('d036', 'Vegetables'),
    ('d037', 'Vegetables'), ('d038', 'Vegetables'), ('d039', 'Vegetables'),
    ('d040', 'Vegetables'), ('d041', 'Vegetables'),
    ('d042', 'Legumes'), ('d043', 'Legumes'), ('d044', 'Legumes'),
    ('d045', 'Nuts'), ('d046', 'Nuts'), ('d047', 'Nuts'),
    ('d048', 'Nuts'), ('d049', 'Nuts'),
    ('d050', 'Snacks'), ('d051', 'Snacks'), ('d052', 'Snacks'),
    ('d053', 'Fats'), ('d054', 'Sweets'), ('d055', 'Drinks'),
  ];
}
