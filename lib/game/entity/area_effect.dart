
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/game.dart';

class AreaEffect extends SpriteAnimationComponent
    with
        CollisionCallbacks,
        HasGameRef<FypGame>,
        AreaEffectVar,
        ShadowOffset,
        CollisionFunction {
  late String type;
  late double duration;

  late double damage;
  late double force;

  @override
  AreaEffect({
    super.animation,
    super.size,
    super.position,
    super.anchor = Anchor.center,
    super.priority,
    //
    this.type = 'BlackHole',
    this.duration = 0.5,
    this.damage = 2,
    this.force = 15,
  });

  double timer = 0;

  @override
  void onMount() async {
    debugMode = true;

    size *= 4;
    duration = 5;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
          loop: false,
        ));

    add(CircleHitbox(
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    await add(SizeEffect.to(size * 2, EffectController(duration: 2)));

    super.onMount();
  }

  @override
  void update(double dt) {
    timer += dt;

    if (timer >= duration) {
      if (type == 'BlackHole') {
        add(SizeEffect.to(size * 0, EffectController(duration: 2)));
      }

      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );
    } else {}
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    switch (type) {
      case 'Collected': // explosion
        Vector2 hit = findDirection(other);

        other.position += (other is! Projectile) ? hit * force : Vector2(0, 0);

        if (other is Obstacle && !other.isBorder) {
          other.hp -= 15;
        }
        if (other is Actor) {
          reduceHP(other, damage);
        }

        if (other is Projectile) {
          other.direction = hit;
        }
        print('aoe bomb');
        break;

      case 'BlackHole': //
        Vector2 direction = findDirection(other);
        if (other is Actor || other is Obstacle) {
          other.position -= (timer >= duration)
              ? direction * 10
              : direction * (1 - (distance(other) / (size.x))) * 3;
          print('bla ${distance(other)} $size');
        }
        if (other is Projectile) {
          // other.position -=
          //     (timer >= duration) ? direction * 10 : Vector2.zero();
          other.velocity -= direction *
              (1 - (distance(other) / size.x)) *
              15; //(size.x / 8).clamp(1, 30);
        }
        break;

      case 'Mist':
        if (other is Actor) {
          other.hp -= damage;
        }
        break;

      default:
        print('aoe default');
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (type == 'BlackHole') {
      if (other is Projectile) {
        // other.velocity = Vector2.all(0);
      }
    }
    super.onCollisionEnd(other);
  }
}
