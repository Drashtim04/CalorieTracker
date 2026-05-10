import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/food_log.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../mappers/food_log_mapper.dart';
import '../models/food_log_model.dart';

class FoodLogRepositoryImpl implements FoodLogRepository {
  FoodLogRepositoryImpl()
      : _box = Hive.box<FoodLogModel>(AppConstants.foodLogBox);

  final Box<FoodLogModel> _box;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<List<FoodLog>> getLogsForDate(DateTime date) async {
    return _box.values
        .where((m) => _isSameDay(m.loggedAt, date))
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  }

  @override
  Future<List<FoodLog>> getLogsForDateRange(
      DateTime start, DateTime end) async {
    return _box.values
        .where((m) =>
            m.loggedAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            m.loggedAt.isBefore(end.add(const Duration(days: 1))))
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  }

  @override
  Future<void> addFoodLog(FoodLog log) async {
    final model = log.toModel();
    await _box.put(log.id, model);
  }

  @override
  Future<void> updateFoodLog(FoodLog log) async {
    final model = log.toModel();
    await _box.put(log.id, model);
  }

  @override
  Future<void> deleteFoodLog(String id) async {
    await _box.delete(id);
  }

  @override
  Future<double> getTotalCaloriesForDate(DateTime date) async {
    final logs = await getLogsForDate(date);
    return logs.fold<double>(0.0, (sum, log) => sum + log.calories);
  }
}
