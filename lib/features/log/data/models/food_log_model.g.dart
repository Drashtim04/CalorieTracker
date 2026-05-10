// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodLogModelAdapter extends TypeAdapter<FoodLogModel> {
  @override
  final int typeId = 1;

  @override
  FoodLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLogModel(
      id: fields[0] as String,
      foodItemId: fields[1] as String,
      foodName: fields[2] as String,
      mealType: fields[3] as String,
      servingSize: fields[4] as double,
      servingUnit: fields[5] as String,
      calories: fields[6] as double,
      protein: fields[7] as double,
      carbohydrates: fields[8] as double,
      fat: fields[9] as double,
      loggedAt: fields[13] as DateTime,
      fiber: fields[10] as double,
      sugar: fields[11] as double,
      sodium: fields[12] as double,
      notes: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLogModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.foodItemId)
      ..writeByte(2)
      ..write(obj.foodName)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.servingSize)
      ..writeByte(5)
      ..write(obj.servingUnit)
      ..writeByte(6)
      ..write(obj.calories)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.carbohydrates)
      ..writeByte(9)
      ..write(obj.fat)
      ..writeByte(10)
      ..write(obj.fiber)
      ..writeByte(11)
      ..write(obj.sugar)
      ..writeByte(12)
      ..write(obj.sodium)
      ..writeByte(13)
      ..write(obj.loggedAt)
      ..writeByte(14)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
