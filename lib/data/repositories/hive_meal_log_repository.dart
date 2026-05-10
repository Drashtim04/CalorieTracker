import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/meal_log_model.dart';
import '../models/meal_type.dart';
import 'meal_log_repository.dart';

/// Hive-backed implementation of [MealLogRepository].
///
/// Uses [AppConstants.mealLogBox] as the Hive box key.
/// Requires [MealLogModelAdapter], [FoodModelAdapter], and [MealTypeAdapter]
/// to be registered before the box is opened.
class HiveMealLogRepository implements MealLogRepository {
  HiveMealLogRepository()
      : _box = Hive.box<MealLogModel>(AppConstants.mealLogBox);

  final Box<MealLogModel> _box;

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Returns true if [a] and [b] fall on the same calendar day.
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Strips time from [dt], returning midnight of that day.
  DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ─── Read ────────────────────────────────────────────────────────────────────

  @override
  Future<List<MealLogModel>> getLogsForDate(DateTime date) async {
    return _box.values
        .where((log) => _isSameDay(log.dateTime, date))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Future<List<MealLogModel>> getLogsForDateRange(
      DateTime start, DateTime end) async {
    final s = _dayOnly(start);
    final e = _dayOnly(end).add(const Duration(days: 1)); // end of that day

    return _box.values
        .where((log) =>
            log.dateTime.isAfter(s.subtract(const Duration(seconds: 1))) &&
            log.dateTime.isBefore(e))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Future<List<MealLogModel>> getLogsByMealType(
      DateTime date, MealType mealType) async {
    final all = await getLogsForDate(date);
    return all.where((log) => log.mealType == mealType).toList();
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  @override
  Future<void> add(MealLogModel log) async {
    if (_box.containsKey(log.id)) {
      throw ArgumentError('MealLog with id "${log.id}" already exists.');
    }
    await _box.put(log.id, log);
  }

  @override
  Future<void> update(MealLogModel log) async {
    await _box.put(log.id, log);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await _box.clear();
  }

  // ─── Aggregation ─────────────────────────────────────────────────────────────

  @override
  Future<double> totalCaloriesForDate(DateTime date) async {
    final logs = await getLogsForDate(date);
    return logs.fold<double>(0.0, (sum, log) => sum + log.totalCalories);
  }
}
