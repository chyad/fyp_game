import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/entity/projectile_function/enemy_projectile.dart';

class Enemy extends Actor with CollisionFunction, EnemySkill {
  @override
  Enemy({
    super.position,
    super.anchor,
    super.children,
    super.size,
    //
    super.character = 'Virtual Guy',
    //
    super.hp = 5,
    super.vision = 200,
    super.moveSpeed = 80,
    this.enemyType = '',
  });

  // map player later, for multi player character
  late Player player;
  String enemyType;

  bool enemyRemove = false;

  double walkTimer = 0;
  double attackTimer = 1;
  double timer = 0;
  double attackCD = 2;

  double range = 250;
  double speed = 150;
  double maxHP = 0;
  double bulletSize = 1;

  String attackType = '';
  String removeType = '';
  List<String> powerup = ['reflect'];
  final random = Random();

  @override
  FutureOr<void> onLoad() async {
    // diamond shape in shadow region
    // character will move to l r rq if from top of bottom
    //
    // add(PolygonHitbox.relative(
    //   [
    //     Vector2(0, 1), // Middle of top wall
    //     Vector2(1, 0), // Middle of right wall
    //     Vector2(0, -1), // Middle of bottom wall
    //     Vector2(-1, 0), // Middle of left wall
    //   ],
    //   // parentSize: size * hitboxOffsetX,
    //   // position: Vector2(width / 2, height / 2 * 1.6),
    //   parentSize: Vector2(size.x * hitboxOffsetX, size.y * hitboxOffsetY),
    //   position: Vector2(width / 2, height),
    //   anchor: Anchor.center,
    //   isSolid: true,
    // ));

    // cusmetic, condition then load things add things.

    size.clamp(Vector2.all(16), Vector2.all(128));
    maxHP = hp;

    if (enemyType == 'boss') {
      vision = 1000;
      moveSpeed = 40;
      hp = 500;
    }

    List<String> attackList = ['ring', 'multi', 'normal'];
    int randomIndex = random.nextInt(attackList.length);

    attackType = attackList[randomIndex];

    powerup = ['reflect'];
    switch (attackType) {
      case 'ring':
        character = 'Mask Dude';
        powerup = ['reflect'];
        double temp = random.nextDouble() * 300;
        range = 500 + temp;
        speed = ((300 - temp) * 0.4).clamp(50, 100);

        break;
      case 'multi':
        character = 'Pink Man';
        range = 300;
        speed = 150;
        powerup = ['reflect'];
        break;
      default:
        character = 'Virtual Guy';
        powerup = ['reflect'];
        List<String> removeFuncList = [
          'ring',
          'explosion',
          'balckhole',
          'mist',
          //
          'empty', 'empty', 'empty', 'empty', 'empty', 'empty',
        ];
        randomIndex = random.nextInt(removeFuncList.length);
        String effect = removeFuncList[randomIndex];
        powerup.add(effect);
        range = 800;

        speed = effect == 'empty' ? 200 : 150;
        sizeOffset = effect == 'empty' ? 1.0 : 1.5;
    }

    double attackCDoffset = random.nextDouble() * 1 - 0.5;
    attackCD = attackType == 'normal' ? 1 + attackCDoffset : 2 + attackCDoffset;

    if (enemyType != 'boss') {
      attackCD *= 2;
    }

    List<String> removeFuncList = [
      'ring',
      'explosion',
      'balckhole',
      'mist',
      //
      'empty', 'empty', 'empty', 'empty', 'empty', 'empty',
    ];
    randomIndex = random.nextInt(removeFuncList.length);
    removeType = removeFuncList[randomIndex];

    SpriteComponent hat = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('Main Characters/$character/Fall (32x32).png'),
        srcSize: Vector2.all(32),
        srcPosition: Vector2(32 * 0, 0), // 0 to 6
      ),
      size: size / 2,
      position: Vector2(width / 2, 0),
      anchor: Anchor.center,
    );

    await add(hat);

    player = game.player;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    priority = position.y.floor();
    if (distance(player) < vision && !player.isFalling) {
      // move toward player

      velocity = attackType == 'normal'
          ? -findDirection(player)
          : findDirection(player);
      if (hp < maxHP * 0.5 && removeType != 'empty') {
        velocity = findDirection(player);
      }
      // rotate character image to player anchor
      // lookAt(gameRef.player.position);
    } else {
      // for sprite animation state

      if (walkTimer > 1) {
        if (Random().nextBool()) {
          double x = random.nextDouble();
          x = random.nextBool() ? x : -x;

          double y = random.nextDouble();
          y = random.nextBool() ? y : -y;
          velocity = Vector2(x, y);
        } else {
          velocity = Vector2.zero();
        }
        walkTimer = 0;
      }

      // rotate character image to top
      // lookAt(Vector2(position.x, 0));
    }

    if (attackTimer > attackCD && distance(player) < range) {
      // game.audio.playSfx('laserShoot.wav');
      Projectile projectile = Projectile(
        position: position.clone() -
            Vector2(0, (size.x.clamp(hitboxMin, hitboxMax / 2) / 2)),
        size: Vector2.all(24) * bulletSize,
        direction: findDirection(player),
        shadowOffsetY: size.x.clamp(hitboxMin, hitboxMax / 2) / 2,
        isPlayer: false,
        powerup: powerup,
        range: range,
        speed: speed,
      );

      switch (attackType) {
        case 'ring':
          int count = enemyType != 'boss'
              ? (random.nextInt(2) + 1) * 3
              : (random.nextInt(4) + 1) * 3 + 3;
          List<Projectile> test = allAngleProj(projectile, count);

          game.cam.world!.addAll(test);
          break;
        case 'multi':
          int count = enemyType != 'boss'
              ? (random.nextInt(4)) + 2
              : (random.nextInt(4) + 1) * 3 + 3;
          List<Projectile> test = multiShot(projectile, count);

          game.cam.world!.addAll(test);
          break;
        default:
          game.cam.world!.add(projectile);
      }
      attackTimer = 0;

      if (enemyType == 'boss') {
        List<String> attackList = ['ring', 'multi', 'normal'];
        int randomIndex = Random().nextInt(attackList.length);

        attackType = attackList[randomIndex];

        switch (attackType) {
          case 'ring':
            powerup = ['reflect'];
            range = 800;
            speed = 100;
            attackCD = 1.5;
            break;
          case 'multi':
            powerup = [];
            range = 400;
            speed = 150;
            attackCD = 2.5;
            break;
          default:
            powerup = ['reflect'];
            List<String> removeFuncList = [
              'ring',
              'explosion',
              'balckhole',
              'mist',
            ];
            randomIndex = random.nextInt(removeFuncList.length);
            String effect = removeFuncList[randomIndex];
            powerup.add(effect);

            range = 1600;
            speed = 250;
            attackCD = 1;
        }
      }
    }

    position += velocity * moveSpeed * dt;
    timer += dt; // cd usage etc
    attackTimer += dt;
    walkTimer += dt;

    borderCheck();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!(hp <= 0)) {
      // or breakable object, npc etc
      if (other is Player) {
        Vector2 hit = findDirection(other);

        if (!other.invicible) {
          // other.position += hit * 15; // to be tune , or add stats for enemy
          other.invicible = true;
          other.updateHP(-2);
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onRemove() {
    // chance
    if (hp <= 0) {
      switch (removeType) {
        case 'ring':
          Projectile temp = Projectile(
              size: Vector2.all(16),
              direction: Vector2.zero(),
              shadowOffsetY: size.x.clamp(8, 64 / 2) / 2,
              powerup: [],
              isPlayer: false);
          game.cam.world!.addAll(allAngleProj(temp, 6));
          break;
        case 'explosion':
          game.cam.world!.add(spawnExplosion(this));
          break;
        case 'balckhole':
          game.cam.world!.add(spawnBlackhole(this));
          break;
        case 'mist':
          game.cam.world!.add(spawnDamageArea(this));
          break;
        default:
      }

      if (Random().nextBool() || enemyType == 'boss') {
        game.cam.world!.add(spawnCoins(this));
      }
      game.room?.entityList.remove(this);

      if (game.cam.world!.children.whereType<Enemy>().isEmpty) {
        if (!game.gameReset) {
          game.saveHiveMap1(game.roomMapList);
        }
      }
    }

    super.onRemove();
  }

  void borderCheck() {
    double x = game.room!.room.tileMap.map.width * 16;
    double y = game.room!.room.tileMap.map.width * 16;

    if (position.x < 0 || position.y < 0 || position.x > x || position.y > y) {
      hp = -1;
    }
  }
}
