import '../../../../core/usecases/usecase.dart';
import '../entities/food_log.dart';
import '../repositories/food_log_repository.dart';

class GetLogsForDate implements UseCase<List<FoodLog>, DateTime> {
  const GetLogsForDate(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<List<FoodLog>> call(DateTime params) {
    return _repository.getLogsForDate(params);
  }
}

class GetLogsForDateRange
    implements UseCase<List<FoodLog>, DateRangeParams> {
  const GetLogsForDateRange(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<List<FoodLog>> call(DateRangeParams params) {
    return _repository.getLogsForDateRange(params.start, params.end);
  }
}

class DateRangeParams {
  const DateRangeParams({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

class AddFoodLog implements UseCase<void, FoodLog> {
  const AddFoodLog(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<void> call(FoodLog params) {
    return _repository.addFoodLog(params);
  }
}

class UpdateFoodLog implements UseCase<void, FoodLog> {
  const UpdateFoodLog(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<void> call(FoodLog params) {
    return _repository.updateFoodLog(params);
  }
}

class DeleteFoodLog implements UseCase<void, String> {
  const DeleteFoodLog(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<void> call(String params) {
    return _repository.deleteFoodLog(params);
  }
}

class GetTotalCaloriesForDate implements UseCase<double, DateTime> {
  const GetTotalCaloriesForDate(this._repository);
  final FoodLogRepository _repository;

  @override
  Future<double> call(DateTime params) {
    return _repository.getTotalCaloriesForDate(params);
  }
}
