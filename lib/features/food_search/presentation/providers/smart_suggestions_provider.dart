import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/food_model.dart';
import '../../../../data/models/meal_log_model.dart';

/// Provides a list of smart food suggestions based on historical logging
/// frequency and the current time of day.
final smartSuggestionsProvider = Provider<List<FoodModel>>((ref) {
  final box = Hive.box<MealLogModel>(AppConstants.mealLogBox);
  final allLogs = box.values;
  
  final now = DateTime.now();
  final isMorning = now.hour < 12;
  final isAfternoon = now.hour >= 12 && now.hour < 17;
  
  // Determine relevant meal types for current time
  final relevantTypes = <String>[];
  if (isMorning) {
    relevantTypes.addAll(['Breakfast', 'Snack']);
  } else if (isAfternoon) {
    relevantTypes.addAll(['Lunch', 'Snack']);
  } else {
    relevantTypes.addAll(['Dinner', 'Snack']);
  }

  // Count frequencies of foods added during these meal types
  final frequencyMap = <String, int>{};
  final foodMap = <String, FoodModel>{}; 

  for (final log in allLogs) {
    if (relevantTypes.contains(log.mealType.label)) {
      for (final food in log.foods) {
        frequencyMap[food.name] = (frequencyMap[food.name] ?? 0) + 1;
        foodMap[food.name] = food;
      }
    }
  }

  // Sort by frequency
  final sortedNames = frequencyMap.keys.toList()
    ..sort((a, b) => frequencyMap[b]!.compareTo(frequencyMap[a]!));

  // Return top 5 suggestions
  return sortedNames.take(5).map((name) => foodMap[name]!).toList();
});
