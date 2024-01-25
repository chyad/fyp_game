import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/game.dart';

void randMap(TiledComponent<FlameGame<World>> room, FypGame game,
    List<PositionComponent> entity,
    {int seed = 0}) {
  final random = (seed == 0) ? Random() : Random(seed);

  int minSectionWidth =
      random.nextInt(7 - 2) + 2; // range 2 to 7 until moving edges

  int min = room.tileMap.map.height ~/ 4; // depth of platform

  //Determine the start position
  int lastHeight = random.nextInt(room.tileMap.map.height - 6 - min) + min;

  //Used to determine which direction to go
  int nextMove = 0;
  //Used to keep track of the current sections width
  int sectionWidth = 0;

  bool sideX = random.nextBool();
  bool sideY = random.nextBool();

  int count0 = 0;
  int count1 = 0;
  int count2 = 0;
  bool place;

  int direction = sideX ? room.tileMap.map.width : room.tileMap.map.height;

  print(
      'min$min $lastHeight, sideX $sideX | sideY $sideY, minSec $minSectionWidth');

  for (var x = 1; x < direction - 1; x++) {
    nextMove = random.nextInt(2);

    if (nextMove == 0 && lastHeight > 0 && sectionWidth > minSectionWidth) {
      lastHeight--;
      sectionWidth = 0;
    } else if (nextMove == 1 &&
        lastHeight < room.tileMap.map.width &&
        sectionWidth > minSectionWidth) {
      lastHeight++;
      sectionWidth = 0;
      minSectionWidth = random.nextInt(5 - 2) + 2;
    }
    //Increment the section width
    sectionWidth++;

    for (var y = lastHeight; y > 0; y--) {
      int temp = random.nextInt(100);

      if (temp < 4) {
        count0++;
        place = true;
      } else if (temp < 40) {
        count1++;
        place = false;
      } else {
        count2++;
        place = false;
      }
      if (y < room.tileMap.map.height) {
        room.tileMap.setTileData(
            layerId: 0,
            x: sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y),
            y: sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x,
            gid: Gid(
              (y == lastHeight) ? 123 : 206, // 35 , 206
              const Flips(
                  horizontally: false,
                  vertically: false,
                  diagonally: false,
                  antiDiagonally: false),
            ));

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

        if (place) {
          room.tileMap.setTileData(
              layerId: 0,
              x: sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y),
              y: sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x,
              gid: const Gid(
                211,
                Flips(
                    horizontally: false,
                    vertically: false,
                    diagonally: false,
                    antiDiagonally: false),
              ));

          final block = Obstacle(
            position: Vector2(
                (sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y)) * 16,
                (sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x) *
                    16),
            size: Vector2(16, 16),
            priority:
                (sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x) *
                    16,
            isBorder: random.nextBool() ? true : false,
            images: game.images,
          );
          entity.add(block);
        }
      }
    }
  }
  print('$count0, $count1, $count2');

  print(
      '${count0 / (count0 + count1 + count2)}, ${count1 / (count0 + count1 + count2)}, ${count2 / (count0 + count1 + count2)}');
}
