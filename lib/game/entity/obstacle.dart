import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/area_effect.dart';
import 'package:fyp_game/game/game.dart';

class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  bool isBorder;

  Images images;

  Obstacle({
    super.position,
    super.size,
    this.isBorder = false,
    required this.images,
    super.priority,
  });

  int hp = 5;

  @override
  FutureOr<void> onLoad() async {
    // if ( not pushable )
    if (isBorder) {
      debugMode = true;
      priority = (position.y + height / 2).floor();

      await add(RectangleHitbox(
        collisionType: CollisionType.passive,
        isSolid: true,
      ));

      SpriteComponent render = SpriteComponent(
        sprite: Sprite(
          images.fromCache('Terrain/Terrain (16x16).png'),
          srcSize: Vector2.all(32),
          srcPosition: Vector2(6 * 32 + 16, 16),
        ),
        size: size,
        position: Vector2(0, 0),
        // anchor: Anchor.center,
      );
      // add(render);
    } else {
      anchor = Anchor.center;

      SpriteComponent hat = SpriteComponent(
        sprite: Sprite(
          images.fromCache('Terrain/Terrain (16x16).png'),
          srcSize: Vector2.all(32),
          srcPosition: Vector2(6 * 32 + 16, 16),
        ),
        size: size,
        position: Vector2(width / 2, height / 2),
        anchor: Anchor.center,
      );
      await add(CircleHitbox(
        isSolid: true,
      ));
      add(hat);
      debugMode = true;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isBorder) {
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
      AreaEffect aoe = AreaEffect(
          size: size,
          position: position.clone(),
          priority: priority,
          duration: 0.5);

      game.cam.world!.add(aoe);
    }

    super.onRemove();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // self check for update position
    if (other is Obstacle && !isBorder) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;
        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2 * 1) - collisionNormal.length;
        collisionNormal.normalize();

        // update self position
        position += collisionNormal.scaled(separationDistance);

        // update other obs position
        if (!other.isBorder) {
          other.position -= collisionNormal.scaled(separationDistance);
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
