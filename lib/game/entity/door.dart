import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/obstacle.dart';

import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/room/room_detail.dart';

class Door extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  Function? onPlayerEnter;

  int upDown = 0;
  int leftRight = 0;

  double spawnOffset = 40;

  Door({
    super.position,
    super.anchor = Anchor.center,
    super.size,
    super.priority,
    //
    this.onPlayerEnter,
    this.upDown = 0,
    this.leftRight = 0,
    Vector2? scale,
    double? angle,
  });

  late Iterable temp;
  late int newX;
  late int newY;

  late RoomDetail nextRoom;
  late Vector2 spawnPoint;

  @override
  void onMount() {
    // debugMode = true;

    newX = game.currentX + leftRight;
    newY = game.currentY + upDown;

    temp = game.roomMapList
        .where((element) => element.xid == newX && element.yid == newY);

    // print('$this id $newX $newY, $temp');

    String img = 'Blue';

    if (temp.isEmpty) {
      // if direction no room, remove | or chance to spawn secret room?
      // print('$this remove');
      game.roomMapList
          .where((element) =>
              element.xid == game.currentX && element.yid == game.currentY)
          .first
          .entityList
          .remove(this);

      removeFromParent();
    } else {
      nextRoom = temp.first;
      nextRoom.visible = true;
      nextRoom.visited = true;

      switch (nextRoom.roomType) {
        case 'boss':
          img = 'Pink';
          break;
        case 'puzzle':
          img = 'Gray';
          break;
        case 'shop':
          img = 'Yellow';
          break;
        default:
      }

      // print('$upDown $leftRight curr ${game.currentX}:${game.currentY}');

      double x = (upDown == 0)
          ? ((leftRight == 1)
              ? spawnOffset
              : (nextRoom.map.tileMap.map.width *
                      nextRoom.map.tileMap.map.tileWidth) -
                  spawnOffset)
          : (nextRoom.map.tileMap.map.width *
                  nextRoom.map.tileMap.map.tileWidth) *
              0.5;

      double y = (leftRight == 0)
          ? ((upDown == 1)
              ? spawnOffset
              : (nextRoom.map.tileMap.map.height *
                      nextRoom.map.tileMap.map.tileHeight) -
                  spawnOffset)
          : (nextRoom.map.tileMap.map.height *
                  nextRoom.map.tileMap.map.tileHeight) *
              0.5;

      spawnPoint = Vector2(x, y);
    }

    // direction, rotate

    // direction room type -> sprite
    sprite = Sprite(game.images.fromCache('Background/$img.png'),
        srcPosition: Vector2.all(0), srcSize: Vector2.all(64));
    add(RectangleHitbox(collisionType: CollisionType.passive));

    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // game.overlays.add(StroopEffectGame.id); // testing puzzle scene render
    bool roomClear =
        game.cam.world!.children.whereType<Enemy>().isNotEmpty ? false : true;

    if (other is Player && roomClear) {
      // AudioManager.playSfx('Blop_1.wav');

      // game.loadRoom2(game.linkedList.head!.value);
      // game.loadRoom2(game.roomTemp);
      // game.loadRoom('room_02');
      // game.loadRoom2();

      if (temp.isNotEmpty && !other.isFalling) {
        game.player.updateHiveData();

        game.player.position = spawnPoint;
        game.player.lastPosition = spawnPoint;

        game.reset();
        game.resumeEngine();

        game.currentX = newX;
        game.currentY = newY;

        game.loadRoomDetail(nextRoom);
      }

      // game.loadRoomDetail(game.roomMapList.first);

      // onPlayerEnter?.call();
    }

    if (other is Obstacle) {
      other.hp = -1;
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
