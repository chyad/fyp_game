import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';

import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/game.dart';

class Projectile extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  late Vector2 direction;
  late double shadowOffsetY;

// Speed of the bullet. // pass from data later
  late double speed = 150;
  late double range;

  Projectile(
    Image image, {
    Vector2? position,
    super.anchor = Anchor.center,
    required Vector2? size,
    required this.direction,
    required this.shadowOffsetY,
    //
    this.speed = 150,
    this.range = 150,
  }) : super.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: 17,
            stepTime: .05,
            textureSize: Vector2.all(32),
          ),
          position: position,
          size: size,
        );

  double hitboxOffsetX = 0.9;

  Vector2 velocity = Vector2.zero();
  late SpriteComponent shade;

  @override
  void onMount() {
    debugMode = true;

    // animation = sprite;

    if (direction == Vector2.all(0)) {
      // fix to facing direction later
      direction = Vector2(1, 0);
    } else {
      // fix to unit vector
      // might use another joystick delta for attack
      direction = direction / sqrt(direction.dot(direction));
    }
    final shape = CircleHitbox(
      anchor: Anchor.center,
      position: Vector2(width / 2, height / 2 + shadowOffsetY),
      radius: (height / 2 * hitboxOffsetX),
      isSolid: true,
    );

    shade = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('HUD/Joystick.png'),
      ),
      size: Vector2(size.x * hitboxOffsetX, size.y / 4),
      position: position + Vector2(0, shadowOffsetY),
      anchor: Anchor.center,
      priority: 1,
    );
    game.cam.world!.add(shade);

    add(shape);
    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      if (!other.isBorder) {
        other.hp -= 1;
        print('$other : ${other.hp}');
        if (other.hp <= 0) {
          other.removeFromParent();
        }
      }

      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.1),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );
    }
    if (other is Enemy) {
      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.01),
          onComplete: () {
            shade.add(RemoveEffect());
            add(RemoveEffect());
          },
        ),
      );
      other.hp -= 1;
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    // direction = (direction + velocity) /
    //     sqrt((direction + velocity).dot(direction + velocity));

    position += ((direction) * speed) * dt + velocity * dt;
    shade.position += ((direction) * speed) * dt + velocity * dt;

    super.update(dt);
  }

  @override
  void onRemove() {
    shade.removeFromParent();
    super.onRemove();
  }

  void removeAnimation() {
    speed *= 0.2;
    speed.clamp(1, 100);

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/Desappearing(96x96).png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.1,
          textureSize: Vector2.all(96),
          loop: false,
        ));

    add(
      OpacityEffect.fadeOut(
        LinearEffectController(0.1),
        onComplete: () {
          add(RemoveEffect());
        },
      ),
    );

    shade.add(
      OpacityEffect.fadeOut(
        LinearEffectController(0.1),
        onComplete: () {
          add(RemoveEffect());
        },
      ),
    );
  }
}
