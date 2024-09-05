import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/entity/enemy.dart';

import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/overlay/draw_puzzle.dart';
import 'package:fyp_game/game/overlay/powerup_menu.dart';

import 'package:fyp_game/game/entity/static_entity/powerup_info.dart';
import 'package:fyp_game/game/overlay/stroop.dart';

class PowerUp extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  PowerUp({
    super.position,
    super.anchor = Anchor.center,
    super.size,
    super.priority,
    //
    Vector2? scale,
    double? angle,
    this.free = false,
    this.menutype = 'shop',
    this.itemCount = -1,
  });

  String menutype;
  bool free;

  bool puzzleClear = false;

  late int randomSeed;
  late int itemCount = -1;

  final List<ItemDes> itemDes = ItemDes.values;
  List<PowerupInfo> item = [];

  int test = 0;
  bool firstInit = true;

  @override
  void onMount() {
    // debugMode = true;

    if (firstInit) {
      initPowerupData();
      itemCount *= 3;
      firstInit = false;
    }

    String img = menutype == 'shop' ? 'shop' : 'puzzle'; // shop
    size = Vector2.all(32);

    // direction room type -> sprite
    sprite = Sprite(game.images.fromCache('Main Characters/$img.png'),
        srcPosition: Vector2.all(0), srcSize: Vector2.all(32));

    priority = position.y.toInt();

    add(RectangleHitbox(
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // game.overlays.add(StroopEffectGame.id); // testing puzzle scene render
    bool roomClear =
        game.cam.world!.children.whereType<Enemy>().isNotEmpty ? false : true;

    if (other is Player && roomClear) {
      game.powerup = this;

      if (!puzzleClear && menutype != 'shop') {
        game.pauseEngine();

        switch (menutype) {
          case 'stroop':
            game.overlays.add(StroopPuzzle.id);
            break;
          case 'draw':
            game.overlays.add(DrawPuzzle.id);
            break;
          default:
        }
      } else {
        game.overlays.add(PowerUpMenu.id);
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void puzzleIsClear() {
    puzzleClear = true;
    menutype = 'clear';
  }

  void initPowerupData() {
    randomSeed = Random().nextInt(game.maxInt);
    final random = Random(randomSeed);

    switch (menutype) {
      case 'shop':
        itemCount = (itemCount == -1) ? random.nextInt(5 + 1) + 30 : itemCount;
        break;
      case 'stroop':
      case 'draw':
        free = true;
        puzzleClear = false;
        itemCount = (itemCount == -1) ? random.nextInt(3 + 1) + 30 : itemCount;
        break;
      case 'clear':
        free = true;
        puzzleClear = true;
        itemCount = (itemCount == -1) ? random.nextInt(3 + 1) + 30 : itemCount;
        break;
      default:
        List<String> puzzle = ['stroop', 'draw'];
        final int randomIndex = Random().nextInt(puzzle.length);
        menutype = puzzle[randomIndex];

        free = true;
        puzzleClear = false;
        itemCount = (itemCount == -1) ? random.nextInt(3 + 1) + 30 : itemCount;
    }

    print('puzzle $menutype : $itemCount');

    // generate list of upgrade
    for (var i = 0; i < itemCount; i++) {
      // weight shuffle
      // Random().nextDouble(1);
      final int randomIndex = Random().nextInt(itemDes.length);
      final ItemDes randomItemDes = itemDes[randomIndex];

      // upgrade value
      final int value = itemValue(randomItemDes);

      final PowerupInfo temp = PowerupInfo(
        itemDes: randomItemDes,
        itemFunction: itemFunction(game, randomItemDes, value),
        cost: free ? 0 : randomItemDes.cost,
        value: value * randomItemDes.baseValue,
      );
      item.add(temp);
    }
  }

  int itemValue(ItemDes item) {
    int value = Random().nextInt(10) + 1;
    switch (item.type) {
      case 'projectile':
        return 1;
      case 'map':
        return 1;
      case 'room':
        print('room, $value ${value.clamp(1, 5)}');
        return value.clamp(1, 5);
      default:
        return value;
    }
  }

  VoidCallback itemFunction(FypGame game, ItemDes item, int value) {
    switch (item.type) {
      case 'heal':
        return () {
          healHp(game, value * item.baseValue.toDouble());
        };
      //
      case 'attack':
      case 'moveSpeed':
      case 'bulletSpeed':
      case 'bulletRange':
        return () {
          game.audio.playSfx('powerUp.wav');
          statsUp(game, value * item.baseValue.toDouble(), item.type);
        };
      case 'bulletSize':
        return () {
          game.audio.playSfx('powerUp.wav');
          statsUp(game, 0.1 * value * item.baseValue.toDouble(), item.type);
        };
      //
      case 'projectile':
        return () {
          game.audio.playSfx('powerUp.wav');

          projUp(game, value * item.baseValue.toDouble(), item.type);
        };
      case 'map':
        return () {
          game.audio.playSfx('mapPowerUp.wav');
          visibleMap(game);
        };
      case 'room':
        return () {
          game.audio.playSfx('mapPowerUp.wav');
          visitedMap(game, value * item.baseValue);
        };
      default:
        return () {};
    }
  }
}
