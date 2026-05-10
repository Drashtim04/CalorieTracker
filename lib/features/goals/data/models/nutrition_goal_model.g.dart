// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionGoalModelAdapter extends TypeAdapter<NutritionGoalModel> {
  @override
  final int typeId = 2;

  @override
  NutritionGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoalModel(
      id: fields[0] as String,
      calorieGoal: fields[1] as double,
      proteinGoal: fields[2] as double,
      carbsGoal: fields[3] as double,
      fatGoal: fields[4] as double,
      waterGoal: fields[5] as double,
      updatedAt: fields[6] as DateTime?,
    )
      ..weightKg = fields[7] as double?
      ..heightCm = fields[8] as double?
      ..age = fields[9] as int?
      ..gender = fields[10] as String?
      ..activityLevel = fields[11] as String?
      ..weightGoal = fields[12] as String?;
  }

  @override
  void write(BinaryWriter writer, NutritionGoalModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.calorieGoal)
      ..writeByte(2)
      ..write(obj.proteinGoal)
      ..writeByte(3)
      ..write(obj.carbsGoal)
      ..writeByte(4)
      ..write(obj.fatGoal)
      ..writeByte(5)
      ..write(obj.waterGoal)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.weightKg)
      ..writeByte(8)
      ..write(obj.heightCm)
      ..writeByte(9)
      ..write(obj.age)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.activityLevel)
      ..writeByte(12)
      ..write(obj.weightGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
