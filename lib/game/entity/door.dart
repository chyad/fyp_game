import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/enemy.dart';

import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';

class Door extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  Function? onPlayerEnter;

  Door({
    super.position,
    super.anchor = Anchor.center,
    super.size,
    super.priority,
    //
    this.onPlayerEnter,
    Vector2? scale,
    double? angle,
  });

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    sprite = Sprite(game.images.fromCache('Background/Blue.png'),
        srcPosition: Vector2.all(0), srcSize: Vector2.all(64));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // game.overlays.add(StroopEffectGame.id); // testing puzzle scene render
    bool roomClear =
        game.cam.world!.children.whereType<Enemy>().isNotEmpty ? false : true;

    if (other is Player || roomClear) {
      // AudioManager.playSfx('Blop_1.wav');

      game.player.updateData();

      game.reset();
      game.resumeEngine();

      // game.loadRoom2(game.linkedList.head!.value);
      // game.loadRoom2(game.roomTemp);
      game.loadRoom('room_02');

      // onPlayerEnter?.call();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
