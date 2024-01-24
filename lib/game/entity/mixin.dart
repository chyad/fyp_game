import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/game.dart';

mixin Status {

  double hp = 50;
}

mixin EnemySkill on Actor{

  sight() {
    vision *= 3;
  }
}

mixin ProjectileStats {
  double speed = 150;
}

mixin AreaEffectVar {

  reduceHP(Actor other, damage) {
    other.hp -= damage;
    print('$other ${other.hp}');
  }
}

mixin CollisionFunction on PositionComponent, ShadowOffset {
  findDirection(PositionComponent other) {
    Vector2 temp = (other.position - position) /
        sqrt((other.position - position).dot(other.position - position));

    return (temp.isNaN || temp.isInfinite) ? Vector2.zero() : temp;
  }
}

mixin SpriteData {
  double stepTime = 0.05;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation removeAnimation;
}

mixin ShadowOffset on PositionComponent {
  double hitboxOffsetX = 0.5;
  double hitboxOffsetY = 0.25;
  Vector2 positionOffset = Vector2(0, 2);

  double hitboxMin = 8;
  double hitboxMax = 64;

  addHitbox() {
    return CircleHitbox(
      radius: size.x.clamp(hitboxMin, hitboxMax) / 2 * hitboxOffsetX,
      position: Vector2(width / 2, height / 2 * positionOffset.y),
      anchor: Anchor.center,
      isSolid: true,
    );
  }

  addShadow(FypGame game) {
    return SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('HUD/Joystick.png'),
      ),
      size: Vector2(size.x * hitboxOffsetX, size.y / 4),
      position: Vector2(width / 2, height),
      anchor: Anchor.center,
      priority: 0,
    );
  }
}

// ui / archi / game /

// to do. merge player / enemy into actor, and maybe obstacle

