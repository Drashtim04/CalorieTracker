// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodItemModelAdapter extends TypeAdapter<FoodItemModel> {
  @override
  final int typeId = 0;

  @override
  FoodItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      servingSize: fields[3] as double,
      servingUnit: fields[4] as String,
      calories: fields[5] as double,
      protein: fields[6] as double,
      carbohydrates: fields[7] as double,
      fat: fields[8] as double,
      fiber: fields[9] as double,
      sugar: fields[10] as double,
      sodium: fields[11] as double,
      isFavorite: fields[12] as bool,
      createdAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItemModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.servingSize)
      ..writeByte(4)
      ..write(obj.servingUnit)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.protein)
      ..writeByte(7)
      ..write(obj.carbohydrates)
      ..writeByte(8)
      ..write(obj.fat)
      ..writeByte(9)
      ..write(obj.fiber)
      ..writeByte(10)
      ..write(obj.sugar)
      ..writeByte(11)
      ..write(obj.sodium)
      ..writeByte(12)
      ..write(obj.isFavorite)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
