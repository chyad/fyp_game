import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/player.dart';

class GamePlatform extends PositionComponent with CollisionCallbacks {
  GamePlatform({
    super.position,
    super.size,
    super.priority = 1,
  });

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    await add(RectangleHitbox(
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.touchingGround += 1;
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {
      other.touchingGround -= 1;
    }

    super.onCollisionEnd(other);
  }
}
