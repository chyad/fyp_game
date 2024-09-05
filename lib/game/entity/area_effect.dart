import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/player.dart';
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
    // debugMode = true;

    // size *= 4;
    // duration = 5;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
          loop: false,
        ));

    animation = type == 'BlackHole'
        ? SpriteAnimation.fromFrameData(
            game.images.fromCache('Main Characters/blackhole.png'),
            SpriteAnimationData.sequenced(
              amount: 16,
              stepTime: 0.2,
              textureSize: Vector2.all(64),
              loop: true,
            ))
        : animation;

    animation = type == 'Mist'
        ? SpriteAnimation.fromFrameData(
            game.images.fromCache('Items/Fruits/Collected.png'),
            SpriteAnimationData.sequenced(
              amount: 1,
              stepTime: 1,
              textureSize: Vector2.all(32),
              texturePosition: Vector2(32 * 4, 0),
              loop: false,
            ))
        : animation;

    add(CircleHitbox(
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    if (type == 'Explosion') {
      game.audio.playSfx('explosion.wav');
    }
    if (type == 'BlackHole') {
      double temp = size.x;
      temp = temp.clamp(64, 128);
      size = Vector2.all(temp);
      duration = 5;
    }
    if (type == 'Mist') {
      double temp = size.x;
      temp = temp.clamp(32, 128);
      size = Vector2.all(temp);
      duration = 5;
    }

    // await add(SizeEffect.to(size * 2, EffectController(duration: 2)));

    super.onMount();
  }

  @override
  void update(double dt) {
    timer += dt;

    if (timer >= duration) {
      if (type == 'BlackHole') {
        print('bh end');
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
      case 'Explosion':
        Vector2 hit = findDirection(other);
        other.position += (other is! Projectile) ? hit * 15 : Vector2(0, 0);

        if (other is Obstacle && !other.unmovable) {
          other.hp -= 15;
        }
        if (other is Player) {
          other.updateHP(-damage);
        }
        if (other is Enemy) {
          reduceHP(other, damage);
        }

        print('aoe bomb');
        break;

      case 'BlackHole': //
        Vector2 direction = findDirection(other);
        if (other is Actor || other is Obstacle) {
          other.position -= (timer >= duration)
              ? direction * 0.1
              : direction * (1 - (distance(other) / (size.x))) * 2;
        }
        // if (other is Projectile) {
        //   // other.position -=
        //   //     (timer >= duration) ? direction * 10 : Vector2.zero();
        //   other.velocity -= direction *
        //       (1 - (distance(other) / size.x)) *
        //       15; //(size.x / 8).clamp(1, 30);
        // }
        break;

      case 'Mist':
        if (other is Enemy) {
          if (timer >= 1) {
            other.hp -= damage;
            timer = 0;
          }
        }
        if (other is Player) {
          if (timer >= 1) {
            other.updateHP(-damage);
            timer = 0;
          }
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
