// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealLogModelAdapter extends TypeAdapter<MealLogModel> {
  @override
  final int typeId = 4;

  @override
  MealLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealLogModel(
      id: fields[0] as String,
      dateTime: fields[1] as DateTime,
      mealType: fields[2] as MealType,
      foods: (fields[3] as List).cast<FoodModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealLogModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.foods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
