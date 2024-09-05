import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:fyp_game/game/entity/door.dart';
import 'package:fyp_game/game/entity/enemy.dart';

import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/static_entity/next_floor.dart';
import 'package:fyp_game/game/entity/static_entity/powerup.dart';
import 'package:fyp_game/game/entity/static_entity/wall_border.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/room/room_detail.dart';

List<int> grid = [35, 123, 211];

List<int> floor = [
  307,
  308,
  309,
  310,
  311,
  323,
  324,
  325,
  326,
  327,
  339,
  340,
  341
];

// 271 cliff

// cliff
void cliffMap(
  RoomDetail room,
  FypGame game, {
  bool hive = false,
}) {
  // up,    t f
  // down,  t t
  // left,  f f
  // right, f t

  final random = Random(room.seed);

  bool up = false;
  bool down = false;
  bool left = false;
  bool right = false;

  late Iterable temp;

  addBorderWall(room.map, room.entityList);

  temp = game.roomMapList.where(
      (element) => element.xid == room.xid && element.yid == room.yid - 1);
  if (temp.isNotEmpty) {
    up = true;
    randMap(
      room.map,
      game,
      room.entityList,
      seed: random.nextInt(game.maxInt),
      sideX: true,
      sideY: false,
      hive: hive,
    );
  }

  temp = game.roomMapList.where(
      (element) => element.xid == room.xid && element.yid == room.yid + 1);
  if (temp.isNotEmpty) {
    down = true;
    randMap(
      room.map,
      game,
      room.entityList,
      seed: random.nextInt(game.maxInt),
      sideX: true,
      sideY: true,
      hive: hive,
    );
  }

  temp = game.roomMapList.where(
      (element) => element.xid == room.xid - 1 && element.yid == room.yid);
  if (temp.isNotEmpty) {
    left = true;
    randMap(
      room.map,
      game,
      room.entityList,
      seed: random.nextInt(game.maxInt),
      sideX: false,
      sideY: false,
      hive: hive,
    );
  }

  temp = game.roomMapList.where(
      (element) => element.xid == room.xid + 1 && element.yid == room.yid);
  if (temp.isNotEmpty) {
    right = true;
    randMap(
      room.map,
      game,
      room.entityList,
      seed: random.nextInt(game.maxInt),
      sideX: false,
      sideY: true,
      hive: hive,
    );
  }

  if (up && down && !(left || right)) {
    List<String> option = ['left', 'right'];
    final int randomIndex = random.nextInt(option.length);
    String bridge = option[randomIndex];

    switch (bridge) {
      case 'random':
        break;
      case 'left':
        left = true;
        randMap(
          room.map,
          game,
          room.entityList,
          seed: random.nextInt(game.maxInt),
          sideX: false,
          sideY: false,
          hive: hive,
        );
        break;
      case 'right':
        right = true;
        randMap(
          room.map,
          game,
          room.entityList,
          seed: random.nextInt(game.maxInt),
          sideX: false,
          sideY: true,
          hive: hive,
        );
        break;
      default:
    }
  }
  if (left && right && !(up || down)) {
    List<String> option = ['up', 'down'];
    final int randomIndex = random.nextInt(option.length);
    String bridge = option[randomIndex];

    switch (bridge) {
      case 'random':
        break;
      case 'up':
        up = true;
        randMap(
          room.map,
          game,
          room.entityList,
          seed: random.nextInt(game.maxInt),
          sideX: true,
          sideY: false,
          hive: hive,
        );

        break;
      case 'down':
        down = true;
        randMap(
          room.map,
          game,
          room.entityList,
          seed: random.nextInt(game.maxInt),
          sideX: true,
          sideY: true,
          hive: hive,
        );

        break;
      default:
    }
  }
}

void randMap(TiledComponent<FlameGame<World>> room, FypGame game,
    List<PositionComponent> entity,
    {int seed = -1,
    bool sideX = false,
    bool sideY = false,
    bool hive = false}) {
  final random = (seed == -1) ? Random() : Random(seed);

  int minSectionWidth = sideX
      ? random.nextInt(7 - 2) + 2
      : random.nextInt(4) + 1; // range 2 to 7 until moving edges

  int min = sideX ? room.tileMap.map.height : room.tileMap.map.width;
  double portion1 = sideX ? 0.15 : 0.1;
  double portion2 = sideX ? 0.3 : 0.15;

  //Determine the start position
  int lastHeight = (random.nextDouble() * min * 0 + min * portion2).round();

  //Used to determine which direction to go
  int nextMove = 0;
  //Used to keep track of the current sections width
  int sectionWidth = 0;

  int obsCount = 0;
  int enemyCount = 0;

  bool place = true;
  bool spawnEnemy = true;

  int direction = sideX ? room.tileMap.map.width : room.tileMap.map.height;

  for (var x = 1; x < direction - 1; x++) {
    nextMove = random.nextInt(2);

    if (nextMove == 0 && lastHeight > 3 && sectionWidth > minSectionWidth) {
      lastHeight--;
      sectionWidth = 0;
      obsCount = 0;
    } else if (nextMove == 1 &&
        lastHeight < room.tileMap.map.width &&
        sectionWidth > minSectionWidth) {
      lastHeight++;
      sectionWidth = 0;
      minSectionWidth =
          sideX ? random.nextInt(7 - 2) + 2 : random.nextInt(4) + 1;
    }
    //Increment the section width
    sectionWidth++;

    spawnEnemy = !hive ? true : false;
    place = !hive ? true : false;

    for (var y = lastHeight; y > 0; y--) {
      int total = room.tileMap.map.height * room.tileMap.map.width;
      int odd = random.nextInt(total);

      spawnEnemy = random.nextBool();
      // place = random.nextBool();
      place = random.nextDouble() < 0.02 ? true : false;

      if (y < room.tileMap.map.height) {
        if (room.tileMap
                .getTileData(
                  layerId: 0,
                  x: sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y),
                  y: sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x,
                )
                ?.tile !=
            307) {
          room.tileMap.setTileData(
              layerId: 0,
              x: sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y),
              y: sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x,
              gid: Gid(
                (y == lastHeight) ? 271 : 307,
                const Flips(
                    horizontally: false,
                    vertically: false,
                    diagonally: false,
                    antiDiagonally: false),
              ));
        }

        // add platform
        if (y == 1) {
          final block = GamePlatform(
            position: Vector2(
                (sideX
                        ? x
                        : (sideY
                            ? room.tileMap.map.width - 1 - lastHeight
                            : y)) *
                    16, // or just y
                (sideX
                        ? (sideY ? room.tileMap.map.height - 1 - lastHeight : y)
                        : x) *
                    16),
            size: Vector2(
                (sideX ? 1 : lastHeight) * 16, (sideX ? lastHeight : 1) * 16),
          );
          entity.add(block);
        }

        if (spawnEnemy && enemyCount < 1 && !hive) {
          if (addEnemy(
              room,
              entity,
              sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y),
              sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x)) {
            enemyCount += 1;
          }
        }

        if (place && obsCount < 3) {
          int sizeOffset = random.nextInt(2) + 1;

          final block = Obstacle(
            position: Vector2(
                    (sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y)) *
                        16,
                    (sideX
                            ? (sideY ? room.tileMap.map.height - 1 - y : y)
                            : x) *
                        16) +
                Vector2(16, 16) * sizeOffset.toDouble() * 0.5,
            size: Vector2(16, 16) * sizeOffset.toDouble(),
            priority:
                (sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x) *
                    16,
            unmovable: random.nextBool() ? true : false,
          );
          if (!hive) {
            entity.add(block);
          }

          obsCount += 1;
        }
      }
    }
  }

  // print(
  //   'min$min $lastHeight, sideX $sideX | sideY $sideY, minSec $minSectionWidth');
  // print('$count0, $count1, $count2');
  // print(
  //     '${count0 / (count0 + count1 + count2)}, ${count1 / (count0 + count1 + count2)}, ${count2 / (count0 + count1 + count2)}');
}

//
void symmetircMap(TiledComponent<FlameGame<World>> room, FypGame game,
    List<PositionComponent> entity,
    {int seed = -1}) {
  final random = (seed == -1) ? Random() : Random(seed);

  int tileX = room.tileMap.map.width;
  int tileY = room.tileMap.map.height;

  bool symmetricHorizontal = random.nextBool();
  bool symmetricVertical = random.nextBool();

  int size = random.nextInt(2) + 3;

  for (var x = 1; (symmetricHorizontal) ? x < tileX / 2 : x < tileX - 1; x++) {
    for (var y = 1; (symmetricVertical) ? y < tileY / 2 : y < tileY - 1; y++) {
      //
      // set tile data and add platform in 4 or 9?

      int placeBlock = 35;
      bool place = random.nextBool();
      if (place) {
        addTileBlock(room, x, y, 2, symmetricHorizontal, symmetricVertical);
      }

      // if (placeBlock < 1) {
      //   n = (n > 250) ? 35 : n;
      //   print('sym : $n $size');
      //   for (var bx = 0; bx < size; bx++) {
      //     for (var by = 0; by < size; by++) {
      //       if (x + bx < tileX - 1 && y + by < tileY - 1) {
      //         addPlatform(room, x + bx, y + by, gid: n);
      //       }
      //     }
      //   }

      //   n += 88;
      // }
    }
  }
}

void bossMap(
  TiledComponent<FlameGame<World>> room,
  FypGame game,
  List<PositionComponent> entity, {
  int seed = -1,
  bool hive = false,
}) {
  final random = (seed == -1) ? Random() : Random(seed);
  int tileX = room.tileMap.map.width;
  int tileY = room.tileMap.map.height;

  bool symmetricHorizontal = true;
  bool symmetricVertical = true;

  addBorderWall(room, entity);
  addFullPlatform(room, entity);

  for (var x = 1; (symmetricHorizontal) ? x < tileX / 2 : x < tileX - 1; x++) {
    for (var y = 1; (symmetricVertical) ? y < tileY / 2 : y < tileY - 1; y++) {
      final int randomIndex = random.nextInt(floor.length);
      int gid = floor[randomIndex];

      int placeBlock = 35;
      int n = random.nextInt(3);
      addTileBlock(room, x, y, 2, symmetricHorizontal, symmetricVertical,
          gid: gid);

      // add entity
    }
  }

  // entity add full platform
}

void addTileBlock(TiledComponent<FlameGame<World>> room, x, y, int size,
    bool symmetricHorizontal, bool symmetricVertical,
    {int gid = 35}) {
  for (var i = -(size - 1) / 2; i <= (size - 1) / 2; i++) {
    for (var j = -(size - 1) / 2; j <= (size - 1) / 2; j++) {
      int xOff = i.toInt();
      int yOff = j.toInt();
      bool skip = checkBoarder(room, x + xOff, y + yOff);

      if (!skip) {
        // top left
        addPlatform(room, x + xOff, y + yOff, gid: gid);

        if (symmetricHorizontal) {
          // top right
          addPlatform(room, (room.tileMap.map.width - (x + xOff) - 1), y + yOff,
              gid: gid);
        }

        if (symmetricVertical) {
          // bl
          addPlatform(
              room, x + xOff, (room.tileMap.map.height - (y + yOff) - 1),
              gid: gid);
        }

        if (symmetricHorizontal && symmetricVertical) {
          // br
          addPlatform(
            room,
            (room.tileMap.map.width - (x + xOff) - 1),
            (room.tileMap.map.height - (y + yOff) - 1),
            gid: gid,
          );
        }
      }
    }
  }
}

void addPlatform(TiledComponent<FlameGame<World>> room, x, y, {gid = 35}) {
  room.tileMap.setTileData(
      layerId: 0,
      x: x,
      y: y,
      gid: Gid(
        gid,
        const Flips(
            horizontally: false,
            vertically: false,
            diagonally: false,
            antiDiagonally: false),
      ));

  // spawn platform
}

void spawnDoor(
    TiledComponent<FlameGame<World>> room, List<PositionComponent> entityList) {
  double horizontal =
      (room.tileMap.map.width * room.tileMap.map.tileWidth).toDouble();
  double vertical =
      (room.tileMap.map.height * room.tileMap.map.tileHeight).toDouble();

  // for(var x = 0; x < 1; x++){
  //   for(var x = 0; x < 1; x++){
  //     //door
  //   }
  // }

  final door = Door(
    position: Vector2(horizontal / 2, 0 + 16),
    size: Vector2.all(24),
    upDown: -1,
  );
  final doorBottom = Door(
    position: Vector2(horizontal / 2, vertical - 16),
    size: Vector2.all(24),
    upDown: 1,
  );

  final ldoor = Door(
    position: Vector2(0 + 16, vertical / 2),
    size: Vector2.all(24),
    leftRight: -1,
  );
  final rdoor = Door(
    position: Vector2(horizontal - 16, vertical / 2),
    size: Vector2.all(24),
    leftRight: 1,
  );

  entityList.addAll([door, doorBottom, ldoor, rdoor]);
}

void spawnNextFloor(
    TiledComponent<FlameGame<World>> room, List<PositionComponent> entityList) {
  double horizontal =
      (room.tileMap.map.width * room.tileMap.map.tileWidth).toDouble();
  double vertical =
      (room.tileMap.map.height * room.tileMap.map.tileHeight).toDouble();

  final nextFloor = NextFloor(
    position: Vector2(horizontal / 2, vertical / 2),
    size: Vector2.all(24),
  );

  entityList.add(nextFloor);
}

void spawnPowerUp(TiledComponent<FlameGame<World>> room,
    List<PositionComponent> entityList, String roomType) {
  double horizontal =
      (room.tileMap.map.width * room.tileMap.map.tileWidth).toDouble();
  double vertical =
      (room.tileMap.map.height * room.tileMap.map.tileHeight).toDouble();

  final powerup = PowerUp(
    position: Vector2(horizontal / 2, vertical / 2),
    size: Vector2.all(24),
    menutype: roomType,
  );

  entityList.add(powerup);
}

bool checkBoarder(TiledComponent<FlameGame<World>> room, x, y) {
  return (x < 1) ||
      (x > room.tileMap.map.width - 1) ||
      (y < 1) ||
      (y > room.tileMap.map.height - 1);
}

void addBorderWall(
    TiledComponent<FlameGame<World>> room, List<PositionComponent> entity) {
  final wall = room.tileMap.getLayer<ObjectGroup>('wall');

  if (wall != null) {
    for (final item in wall.objects) {
      switch (item.class_) {
        case 'wall':
          final wall = WallBorder(
            position: Vector2(item.x, item.y),
            size: Vector2(item.width, item.height),
          );
          entity.add(wall);
          break;
      }
    }
  }
}

void addFullPlatform(
    TiledComponent<FlameGame<World>> room, List<PositionComponent> entity) {
  final floor = GamePlatform(
    position: Vector2.all(room.tileMap.map.tileWidth.toDouble()),
    size: Vector2(
        ((room.tileMap.map.width - 2) * room.tileMap.map.tileWidth).toDouble(),
        ((room.tileMap.map.height - 2) * room.tileMap.map.tileHeight)
            .toDouble()),
  );
  entity.add(floor);
}

bool addEnemy(TiledComponent<FlameGame<World>> room,
    List<PositionComponent> entity, int x, int y) {
  double xCount = room.tileMap.map.width * 0.3;
  double yCount = room.tileMap.map.height * 0.3;

  if (x < xCount ||
      y < yCount ||
      x > room.tileMap.map.width - xCount ||
      y > room.tileMap.map.height - yCount) {
    return false;
  }

  final random = Random();
  double sizeOffset = random.nextDouble() * 1 + 0.75;
  int visionMultiplier = random.nextInt(7 + 1);
  int hpMultiplier = random.nextInt(4 + 1);

  final enemy = Enemy(
    position: Vector2(x * room.tileMap.map.tileWidth.toDouble(),
        y * room.tileMap.map.tileHeight.toDouble()),
    size: Vector2.all(32) * sizeOffset,
    vision: 300,
    moveSpeed: 30.0 + 5 * (4 - hpMultiplier),
    hp: 30.0 + 5 * hpMultiplier,
  );

  entity.add(enemy);
  return true;
}

void addObstacle(
  TiledComponent<FlameGame<World>> room,
  List<PositionComponent> entity,
  String roomType,
  double x,
  double y,
  double size,
  bool trap,
) {
  // todo
  final random = Random();

  final obs = Obstacle(
    position: Vector2(x, y),
    size: Vector2.all(size),
    trap: trap,
  );

  entity.add(obs);
}

void addEnemyFull(TiledComponent<FlameGame<World>> room,
    List<PositionComponent> entity, String roomType) {
  final random = Random();
  int count = roomType == 'boss'
      ? random.nextInt(1 + 1) + 1
      : random.nextInt(3 + 1) + 2;

  for (var i = 0; i < count; i++) {
    int x = random.nextInt(room.tileMap.map.width -
            (room.tileMap.map.width * 0.3).round() * 2) +
        (room.tileMap.map.width * 0.3).round();
    int y = random.nextInt(room.tileMap.map.height -
            (room.tileMap.map.height * 0.3).round() * 2) +
        (room.tileMap.map.height * 0.3).round();

    double sizeOffset = random.nextDouble() * 1 + 0.75;
    int visionMultiplier = random.nextInt(7 + 1);
    int hpMultiplier = random.nextInt(4 + 1);

    final enemy = Enemy(
      position: Vector2(x * room.tileMap.map.tileWidth.toDouble(),
          y * room.tileMap.map.tileHeight.toDouble()),
      size: Vector2.all(32) * sizeOffset,
      vision: 300,
      moveSpeed: 30.0 + 5 * (4 - hpMultiplier),
      hp: 30.0 + 5 * hpMultiplier,
    );

    entity.add(enemy);
  }
}

void addBossEnemy(TiledComponent<FlameGame<World>> room,
    List<PositionComponent> entity, String roomType) {
  final random = Random();
  int count = random.nextInt(1 + 1) + 1;

  double x = count == 1
      ? room.tileMap.map.width * 0.5 * room.tileMap.map.tileWidth
      : room.tileMap.map.width * room.tileMap.map.tileWidth * 0.3;
  double y = count == 1
      ? room.tileMap.map.height * 0.5 * room.tileMap.map.tileHeight
      : room.tileMap.map.height * 0.3 * room.tileMap.map.tileHeight;

  for (var i = 0; i < count; i++) {
    final enemy = Enemy(
      position: Vector2(x, y),
      size: Vector2.all(32) * 4 / count.toDouble(),
      vision: 1000 / count,
      moveSpeed: 40 / count,
      hp: 500 / count,
      enemyType: 'boss',
    );
    entity.add(enemy);

    x = x / 0.3 * 0.7;
    y = y / 0.3 * 0.7;
  }
}

void addHiveEntity(
    List<HiveEntity> hiveEntity, List<PositionComponent> entity) {
  late PositionComponent item;
  for (var element in hiveEntity) {
    switch (element.entityType) {
      case 'obstacle':
        item = Obstacle(
          unmovable: (element.name == 'unmovalbe') ? true : false,
          position: Vector2(element.position[0], element.position[1]),
          size: Vector2(element.size[0], element.size[1]),
        );
        entity.add(item);
        break;
      case 'enemy':
        item = Enemy(
          enemyType: element.name,
          position: Vector2(element.position[0], element.position[1]),
          size: Vector2(element.size[0], element.size[1]),
        );
        entity.add(item);
        break;
      case 'powerup':
        print('hive pu itemcount : ${element.other}');
        item = PowerUp(
          menutype: element.name,
          position: Vector2(element.position[0], element.position[1]),
          size: Vector2(element.size[0], element.size[1]),
          itemCount: int.parse(element.other),
        );
        entity.add(item);
        break;
      default:
    }
  }
}
