import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter/material.dart';
import 'package:fyp_game/game/entity/door.dart';
import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/item.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/room/map.dart';

class Room extends World with HasGameRef<FypGame> {
  late TiledComponent room;

  late String roomName;

  late Rect roomBounds;

  Room({this.roomName = 'room_02'});

  @override
  FutureOr<void> onLoad() async {
    room = await TiledComponent.load('$roomName.tmx', Vector2.all(16));

    randMap(room, seed: 0);
    randMap(room, seed: 0);

    game.linkedList.add(room);

    game.linkedList.printList();

    print(this);

    add(room);

    roomBounds = Rect.fromLTWH(
        0 + 16,
        0 + 16,
        (room.tileMap.map.width * room.tileMap.map.tileWidth).toDouble() - 32,
        (room.tileMap.map.height * room.tileMap.map.tileHeight).toDouble() -
            32);

    spawnActors(room);
    setupCamera(room);

    spawnDoor(room);

    return super.onLoad();
  }

  void spawnActors(TiledComponent level) {
    final tileMap = level.tileMap;

    final obstaclesLayer = tileMap.getLayer<ObjectGroup>('Obstacle');

    if (obstaclesLayer != null) {
      for (final collision in obstaclesLayer.objects) {
        switch (collision.class_) {
          case 'Border': // later use
            final block = Obstacle(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isBorder: true,
              images: game.images,
            );
            add(block);
            break;

          default:
            final block = Obstacle(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              images: game.images,
            );
            add(block);
            break;
        }
      }
    }

    final spawnPointLayer = tileMap.getLayer<ObjectGroup>('Actor');

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            game.player = Player(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              // character: 'Virtual Guy',
              children: [
                BoundedPositionBehavior(bounds: Rectangle.fromRect(roomBounds)),
              ],
              size: Vector2.all(32),
            );
            game.player.setData(game.playerData);
            add(game.player);
            break;

          case 'Enemy':
            final enemy = Enemy(
              character: 'Pink Man',
            );
            enemy.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(enemy);
            break;

          case 'Item':
            final item = Item(
              images: game.images,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(item);
            break;

          case 'Door': // temp, should use for level (room) switching later
            final door = Door(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2.all(24),
              priority: spawnPoint.y.floor(),
            );
            add(door);
            break;
          default:
        }
      }
    }
  }

  void setupCamera(TiledComponent room) {
    game.cam.follow(game.player, maxSpeed: 200);
    game.cam.setBounds(
      Rectangle.fromLTRB(
        game.fixedResolution.x / 2,
        game.fixedResolution.y / 2,
        room.width - game.fixedResolution.x / 2,
        room.height - game.fixedResolution.y / 2,
      ),
    );
  }

  void randomBackground(TiledComponent<FlameGame<World>> room) {
    final random = Random();

    int next(int min, int max) => min + random.nextInt(max - min);
    int count0 = 0;
    int count1 = 0;
    int count2 = 0;

    bool place = false;

    for (var x = 1; x < room.tileMap.map.width - 1; x++) {
      for (var y = 1; y < room.tileMap.map.height - 1; y++) {
        int temp = Random().nextInt(100);

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

        if (place) {
          room.tileMap.setTileData(
              layerId: 0,
              x: x,
              y: y,
              gid: const Gid(
                35,
                Flips(
                    horizontally: false,
                    vertically: false,
                    diagonally: false,
                    antiDiagonally: false),
              ));

          final block = Obstacle(
            position: Vector2(x * 16, y * 16),
            size: Vector2(16, 16),
            isBorder: true,
            images: game.images,
          );
          add(block);
        } else {
          room.tileMap.setTileData(
              layerId: 0,
              x: x,
              y: y,
              gid: const Gid(
                24,
                Flips(
                    horizontally: false,
                    vertically: false,
                    diagonally: false,
                    antiDiagonally: false),
              ));
        }
      }
    }

    print('$count0, $count1, $count2');

    print(
        '${count0 / (room.tileMap.map.width * room.tileMap.map.height)}, ${count1 / (room.tileMap.map.width * room.tileMap.map.height)}, ${count2 / (room.tileMap.map.width * room.tileMap.map.height)}');
  }

  void randMap(TiledComponent<FlameGame<World>> room, {int seed = 0}) {
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
                          ? (sideY
                              ? room.tileMap.map.height - 1 - lastHeight
                              : y)
                          : x) *
                      16),
              size: Vector2(
                  (sideX ? 1 : lastHeight) * 16, (sideX ? lastHeight : 1) * 16),
            );
            add(block);
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
                  (sideX ? x : (sideY ? room.tileMap.map.width - 1 - y : y)) *
                      16,
                  (sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x) *
                      16),
              size: Vector2(16, 16),
              priority:
                  (sideX ? (sideY ? room.tileMap.map.height - 1 - y : y) : x) *
                      16,
              isBorder: random.nextBool() ? true : false,
              images: game.images,
            );
            add(block);
          }
        }
      }
    }
    print('$count0, $count1, $count2');

    print(
        '${count0 / (count0 + count1 + count2)}, ${count1 / (count0 + count1 + count2)}, ${count2 / (count0 + count1 + count2)}');
  }

  void spawnDoor(TiledComponent<FlameGame<World>> room) {
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
    );
    final doorBottom = Door(
      position: Vector2(horizontal / 2, vertical - 16),
      size: Vector2.all(24),
    );
    final ldoor = Door(
      position: Vector2(0 + 16, vertical / 2),
      size: Vector2.all(24),
    );
    final rdoor = Door(
      position: Vector2(horizontal - 16, vertical / 2),
      size: Vector2.all(24),
    );

    addAll([door, doorBottom, ldoor, rdoor]);
  }
}
