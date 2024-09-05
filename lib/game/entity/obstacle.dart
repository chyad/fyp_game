import 'dart:async';
import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/area_effect.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/entity/projectile_function/enemy_projectile.dart';
import 'package:fyp_game/game/entity/static_entity/wall_border.dart';
import 'package:fyp_game/game/game.dart';

class Obstacle extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  bool unmovable;

  Obstacle({
    super.position,
    super.size,
    super.anchor = Anchor.center,
    this.unmovable = false,
    super.priority,
    this.trap = true,
  });

  bool trap;
  String trapType = '';
  int hp = 5;

  final random = Random();

  @override
  FutureOr<void> onLoad() async {
    // if ( not pushable )
    if (unmovable) {
      // debugMode = true;
      priority = (position.y + height / 2).floor();

      await add(RectangleHitbox(
        collisionType: CollisionType.passive,
        isSolid: true,
      ));
    } else {
      anchor = Anchor.bottomCenter;
      // position += size / 2;

      await add(CircleHitbox(
        radius: size.x / 2,
        position: Vector2(width / 2, height / 2 * 2),
        anchor: Anchor.center,
        isSolid: true,
      ));

      SpriteComponent shade = SpriteComponent(
        sprite: Sprite(
          game.images.fromCache('HUD/Joystick.png'),
        ),
        size: Vector2(size.x * 1.2, size.y / 2),
        position: Vector2(width / 2, height),
        anchor: Anchor.center,
        priority: 1,
      );
      add(shade);

      // debugMode = true;

      List<String> trapList = [
        'ring',
        'explosion',
        'balckhole',
        'mist',
        //
        'empty', 'empty', 'empty', 'empty'
      ];
      int randomIndex = random.nextInt(trapList.length);
      trapType = trap ? trapList[randomIndex] : '';
    }

    String img = unmovable ? '3' : '2';

    sprite = Sprite(game.images.fromCache('Items/Boxes/Box1/${img}_Idle.png'),
        srcPosition: Vector2.all(0), srcSize: Vector2.all(22));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!unmovable) {
      priority = position.y.floor();
    }

    if (hp <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    if (hp <= 0) {
      switch (trapType) {
        case 'ring':
          Projectile temp = Projectile(
              size: Vector2.all(16),
              direction: Vector2.zero(),
              shadowOffsetY: size.x.clamp(8, 64 / 2) / 2,
              powerup: []);
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

      if (random.nextBool()) {
        game.cam.world!.add(spawnCoins(this));
      }

      game.room?.entityList.remove(this);
    }

    super.onRemove();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // self check for update position
    if ((other is Obstacle || other is WallBorder) && !unmovable) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;
        final collisionNormal =
            absoluteCenter - mid + Vector2(0, (2 / 2 - 0.5) * height);

        final separationDistance = (size.x / 2 * 1) - collisionNormal.length;
        collisionNormal.normalize();

        // update self position
        position += collisionNormal.scaled(separationDistance);

        // update other obs position
        if (other is Obstacle && !other.unmovable) {
          other.position -= collisionNormal.scaled(separationDistance);
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
