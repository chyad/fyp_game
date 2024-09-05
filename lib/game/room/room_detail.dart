import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RoomDetail with HiveObjectMixin {
  int seed = -1;
  int xid = 0;
  int yid = 0;

  String roomType = ''; // for setting door sprite later

  late TiledComponent map;

  List<PositionComponent> entityList = [];

  bool roomClear = false;

  bool visible = false;
  bool visited = false;
  // entitylist
  // door ?

  RoomDetail({
    this.seed = -1,
    this.xid = 0,
    this.yid = 0,
    this.roomType = '',
    required this.map,
    required this.entityList,
    //
    this.roomClear = false,
    this.visible = false,this.visited = false,
  });
}
