import '../models/meal_log_model.dart';
import '../models/meal_type.dart';

/// Contract for meal-log persistence operations.
abstract class MealLogRepository {
  /// Returns all meal logs for a given [date] (day-level granularity),
  /// sorted ascending by [MealLogModel.dateTime].
  Future<List<MealLogModel>> getLogsForDate(DateTime date);

  /// Returns all meal logs whose date falls within [[start], [end]],
  /// inclusive on both ends. Useful for weekly/monthly progress queries.
  Future<List<MealLogModel>> getLogsForDateRange(DateTime start, DateTime end);

  /// Returns all logs for [date] that match [mealType].
  Future<List<MealLogModel>> getLogsByMealType(
      DateTime date, MealType mealType);

  /// Saves a new meal log. Throws if the id already exists.
  Future<void> add(MealLogModel log);

  /// Updates an existing meal log identified by [log.id].
  Future<void> update(MealLogModel log);

  /// Deletes the meal log with [id]. No-op if not found.
  Future<void> delete(String id);

  /// Aggregated calorie total for a given [date].
  Future<double> totalCaloriesForDate(DateTime date);

  /// Removes all meal logs. Use with caution.
  Future<void> deleteAll();
}
