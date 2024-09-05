// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMapdaAdapter extends TypeAdapter<HiveMapda> {
  @override
  final int typeId = 10;

  @override
  HiveMapda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMapda(
      map: (fields[0] as List).cast<HiveRoom2>(),
      currentX: fields[1] as int,
      currentY: fields[2] as int,
      playerPos: (fields[3] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveMapda obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.map)
      ..writeByte(1)
      ..write(obj.currentX)
      ..writeByte(2)
      ..write(obj.currentY)
      ..writeByte(3)
      ..write(obj.playerPos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMapdaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveRoom2Adapter extends TypeAdapter<HiveRoom2> {
  @override
  final int typeId = 11;

  @override
  HiveRoom2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveRoom2(
      seed: fields[0] as int,
      roomX: fields[1] as int,
      roomY: fields[2] as int,
      roomType: fields[3] as String,
      roomClear: fields[4] as bool,
      visible: fields[5] as bool,
      visited: fields[6] as bool,
      entityList: (fields[7] as List).cast<HiveEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveRoom2 obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.seed)
      ..writeByte(1)
      ..write(obj.roomX)
      ..writeByte(2)
      ..write(obj.roomY)
      ..writeByte(3)
      ..write(obj.roomType)
      ..writeByte(4)
      ..write(obj.roomClear)
      ..writeByte(5)
      ..write(obj.visible)
      ..writeByte(6)
      ..write(obj.visited)
      ..writeByte(7)
      ..write(obj.entityList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveRoom2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveEntityAdapter extends TypeAdapter<HiveEntity> {
  @override
  final int typeId = 12;

  @override
  HiveEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveEntity(
      entityType: fields[0] as String,
      name: fields[1] as String,
      position: (fields[2] as List).cast<double>(),
      size: (fields[3] as List).cast<double>(),
      other: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.entityType)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.other);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
