import 'dart:async';

import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/player.dart';


class Enemy extends Actor with CollisionFunction, EnemySkill {
  @override
  Enemy({
    super.character = 'Ninja Frog',
    //
    super.hp = 5,
    super.vision = 50,
    super.moveSpeed = 50,
    super.size,
  });

  // map player later, for multi player character
  late Player player;


  double timer = 0;

  @override
  FutureOr<void> onLoad() async {
    // diamond shape in shadow region
    // character will move to l r rq if from top of bottom
    //
    // add(PolygonHitbox.relative(
    //   [
    //     Vector2(0, 1), // Middle of top wall
    //     Vector2(1, 0), // Middle of right wall
    //     Vector2(0, -1), // Middle of bottom wall
    //     Vector2(-1, 0), // Middle of left wall
    //   ],
    //   // parentSize: size * hitboxOffsetX,
    //   // position: Vector2(width / 2, height / 2 * 1.6),
    //   parentSize: Vector2(size.x * hitboxOffsetX, size.y * hitboxOffsetY),
    //   position: Vector2(width / 2, height),
    //   anchor: Anchor.center,
    //   isSolid: true,
    // ));

    // cusmetic, condition then load things add things.

    size.clamp(Vector2.all(32), Vector2.all(128));

    SpriteComponent hat = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('Main Characters/$character/Fall (32x32).png'),
        srcSize: Vector2.all(32),
        srcPosition: Vector2(32 * 0, 0), // 0 to 6
      ),
      size: size / 2,
      position: Vector2(width / 2, 0),
      anchor: Anchor.center,
    );

    await add(hat);

    player = game.cam.world!.children.whereType<Player>().last;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    priority = position.y.floor();
    if (distance(player) < vision && !player.isFalling) {
      print(hp);
      // move toward player
      velocity = findDirection(player);

      position += velocity * moveSpeed * dt;

      // rotate character image to player anchor
      // lookAt(gameRef.player.position);
    } else {
      // for sprite animation state
      velocity = Vector2.zero();

      // rotate character image to top
      // lookAt(Vector2(position.x, 0));
    }

    timer += dt; // cd usage etc

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!(hp <= 0)) {
      // or breakable object, npc etc
      if (other is Player) {
        Vector2 hit = findDirection(other);

        if (!other.invicible) {
          // other.position += hit * 15; // to be tune , or add stats for enemy
          other.invicible = true;
          other.hp -= 1;

          print('hit, $other : ${other.hp}');
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

}
