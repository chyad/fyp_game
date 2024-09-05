import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp_game/game/room/room_detail.dart';
import 'package:hive/hive.dart';

part 'map_data.g.dart';

@HiveType(typeId: 10)
class HiveMapda extends ChangeNotifier with HiveObjectMixin {
  static const String hiveMapBox = 'HiveMapdaBox';
  static const String hiveMapKey = 'HiveMapda';

  @HiveField(0)
  List<HiveRoom2> map;

  @HiveField(1)
  int currentX;
  @HiveField(2)
  int currentY;

  @HiveField(3)
  List<double> playerPos;

  HiveMapda({
    required this.map,
    required this.currentX,
    required this.currentY,
    required this.playerPos,
  });
}

@HiveType(typeId: 11)
class HiveRoom2 extends HiveObject {
  HiveRoom2({
    required this.seed,
    required this.roomX,
    required this.roomY,
    required this.roomType,
    this.roomClear = false,
    this.visible = false,
    this.visited = false,
    required this.entityList,
  });

  @HiveField(0)
  int seed;
  @HiveField(1)
  int roomX;
  @HiveField(2)
  int roomY;
  @HiveField(3)
  String roomType;

  @HiveField(4)
  bool roomClear;

  @HiveField(5)
  bool visible = false;
  @HiveField(6)
  bool visited = false;

  @HiveField(7)
  List<HiveEntity> entityList;
}

@HiveType(typeId: 12)
class HiveEntity extends HiveObject {
  HiveEntity({
    required this.entityType,
    required this.name,
    required this.position,
    required this.size,
    required this.other,
  });

  @HiveField(0)
  String entityType; // class type
  @HiveField(1)
  String name; // for assets and smaller type

  @HiveField(2)
  List<double> position;
  @HiveField(3)
  List<double> size;
  @HiveField(4)
  String other;
}
