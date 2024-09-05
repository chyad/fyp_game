import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/enemy.dart';

import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';

class NextFloor extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  NextFloor({
    super.position,
    super.anchor = Anchor.center,
    super.size,
    super.priority,
    //
    Vector2? scale,
    double? angle,
  });

  late Iterable temp;

  @override
  void onMount() {
    // debugMode = true;

    // direction room type -> sprite
    sprite = Sprite(game.images.fromCache('Background/Yellow.png'),
        srcPosition: Vector2.all(0), srcSize: Vector2.all(64));
    add(RectangleHitbox(collisionType: CollisionType.passive));

    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // game.overlays.add(StroopEffectGame.id); // testing puzzle scene render
    bool roomClear =
        game.cam.world!.children.whereType<Enemy>().isNotEmpty ? false : true;

    if (other is Player && roomClear) {
      // AudioManager.playSfx('Blop_1.wav');

      game.currentX = 0;
      game.currentY = 0;

      game.newFloor();

      // game.loadRoomDetail(game.roomMapList.first);

      // onPlayerEnter?.call();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
