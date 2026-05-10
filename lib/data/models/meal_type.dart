import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';

part 'meal_type.g.dart';

/// Represents the type of meal for a log entry.
@HiveType(typeId: AppConstants.mealTypeAdapterTypeId)
enum MealType {
  @HiveField(0)
  breakfast,

  @HiveField(1)
  lunch,

  @HiveField(2)
  dinner,

  @HiveField(3)
  snack;

  /// Human-readable display label
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  /// Icon name hint for the UI layer
  String get iconKey {
    switch (this) {
      case MealType.breakfast:
        return 'wb_sunny';
      case MealType.lunch:
        return 'restaurant';
      case MealType.dinner:
        return 'nightlight';
      case MealType.snack:
        return 'cookie';
    }
  }

  /// Parse from a raw string (case-insensitive), defaults to [snack]
  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => MealType.snack,
    );
  }

  /// All values as display labels
  static List<String> get labels => MealType.values.map((e) => e.label).toList();
}
