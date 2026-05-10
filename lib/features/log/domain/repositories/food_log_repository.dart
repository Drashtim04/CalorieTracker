import '../entities/food_log.dart';

abstract class FoodLogRepository {
  /// Get all logs for a specific date
  Future<List<FoodLog>> getLogsForDate(DateTime date);

  /// Get logs for a date range (for progress charts)
  Future<List<FoodLog>> getLogsForDateRange(DateTime start, DateTime end);

  /// Add a food log entry
  Future<void> addFoodLog(FoodLog log);

  /// Update a food log entry
  Future<void> updateFoodLog(FoodLog log);

  /// Delete a food log by ID
  Future<void> deleteFoodLog(String id);

  /// Get total calories for a specific date
  Future<double> getTotalCaloriesForDate(DateTime date);
}
