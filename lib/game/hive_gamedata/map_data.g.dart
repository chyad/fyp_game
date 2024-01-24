// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameMapAdapter extends TypeAdapter<GameMap> {
  @override
  final int typeId = 1;

  @override
  GameMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameMap(
      room: fields[0] as LinkedList<TiledComponent<FlameGame<World>>>,
      entity: (fields[1] as List).cast<PositionComponent>(),
    );
  }

  @override
  void write(BinaryWriter writer, GameMap obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.room)
      ..writeByte(1)
      ..write(obj.entity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
