import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:fyp_game/game/room/map.dart';
import 'package:hive/hive.dart';

part 'map_data.g.dart';

@HiveType(typeId: 1)
class GameMap extends HiveObject {
  @HiveField(0)
  LinkedList<TiledComponent<FlameGame<World>>> room;
  @HiveField(1)
  List<PositionComponent> entity;

  GameMap({
    required this.room,
    required this.entity,
  });
}
