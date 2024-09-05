import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/game.dart';

class WallBorder extends PositionComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  WallBorder({
    super.position,
    super.size,
  });


  @override
  FutureOr<void> onLoad() async {
    await add(RectangleHitbox(
      collisionType: CollisionType.passive,
      isSolid: true,
    ));

    return super.onLoad();
  }
}
