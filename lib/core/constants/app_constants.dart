class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Calorie Tracker';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String foodItemsBox = 'foodItemsBox';
  static const String foodLogBox = 'foodLogBox';
  static const String goalsBox = 'goalsBox';
  static const String foodBox = 'foodBox';
  static const String mealLogBox = 'mealLogBox';
  static const String settingsBox = 'settingsBox';

  // Hive Type IDs — legacy feature models
  static const int foodItemModelTypeId = 0;
  static const int foodLogModelTypeId = 1;
  static const int nutritionGoalModelTypeId = 2;

  // Hive Type IDs — core data models
  static const int foodModelTypeId = 3;
  static const int mealLogModelTypeId = 4;
  static const int mealTypeAdapterTypeId = 5;

  // Default Nutritional Goals
  static const double defaultCalorieGoal = 2000.0;
  static const double defaultProteinGoal = 150.0;
  static const double defaultCarbsGoal = 250.0;
  static const double defaultFatGoal = 65.0;
  static const double defaultWaterGoal = 2500.0; // ml

  // Meal Types
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snack = 'Snack';

  static const List<String> mealTypes = [
    breakfast,
    lunch,
    dinner,
    snack,
  ];

  // Food Categories
  static const List<String> foodCategories = [
    'Grains & Cereals',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat & Poultry',
    'Seafood',
    'Legumes',
    'Nuts & Seeds',
    'Beverages',
    'Snacks',
    'Sweets & Desserts',
    'Oils & Fats',
    'Condiments',
    'Other',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
