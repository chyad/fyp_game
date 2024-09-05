// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerDataAdapter extends TypeAdapter<PlayerData> {
  @override
  final int typeId = 0;

  @override
  PlayerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerData(
      character: fields[0] as String,
      hp: fields[1] as double,
      attack: fields[10] as double,
      sizeOffset: fields[2] as double,
      moveSpeed: fields[3] as double,
      bulletSize: fields[4] as double,
      bulletSpeed: fields[5] as double,
      bulletRange: fields[9] as double,
      powerup: (fields[6] as List).cast<String>(),
      money: fields[8] as int,
    ).._highScore = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, PlayerData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.character)
      ..writeByte(1)
      ..write(obj.hp)
      ..writeByte(10)
      ..write(obj.attack)
      ..writeByte(2)
      ..write(obj.sizeOffset)
      ..writeByte(3)
      ..write(obj.moveSpeed)
      ..writeByte(4)
      ..write(obj.bulletSize)
      ..writeByte(5)
      ..write(obj.bulletSpeed)
      ..writeByte(9)
      ..write(obj.bulletRange)
      ..writeByte(6)
      ..write(obj.powerup)
      ..writeByte(7)
      ..write(obj._highScore)
      ..writeByte(8)
      ..write(obj.money);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  final int typeId = 1;

  @override
  ItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemType.Apple;
      case 1:
        return ItemType.Bananas;
      case 2:
        return ItemType.Kiwi;
      default:
        return ItemType.Apple;
    }
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    switch (obj) {
      case ItemType.Apple:
        writer.writeByte(0);
        break;
      case ItemType.Bananas:
        writer.writeByte(1);
        break;
      case ItemType.Kiwi:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
