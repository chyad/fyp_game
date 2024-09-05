import 'dart:async';
import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';

enum Fruit {
  coin,
  gem1,
  gem2,
  gem3,
}

class Item extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  List<Fruit> fruits = Fruit.values;

  Item({
    super.position,
    super.anchor = Anchor.center,
    Vector2? size,
    Vector2? scale,
    double? angle,
    super.priority = 10000,
  }) : super(
          size: Vector2.all(16),
        );

  String itemType = '';

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;

    final int randomIndex = Random().nextInt(fruits.length);
    final Fruit randomFruit = fruits[randomIndex];

    itemType = randomFruit.name;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Gems/${randomFruit.name}.png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: .1,
          textureSize: Vector2.all(16),
        ));

    add(CircleHitbox(
      anchor: Anchor.center,
      position: Vector2(width / 2, height / 2),
      radius: height * 0.6,
    )..collisionType = CollisionType.passive);

    await add(
      MoveEffect.by(
        Vector2(0, -4),
        EffectController(
          alternate: true,
          infinite: true,
          duration: 1,
          curve: Curves.ease,
        ),
      ),
    );

    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      // sfx
      game.audio.playSfx('pickupCoin.wav');
      other.money +=150;
      other.updateHP(0);

      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.05,
            textureSize: Vector2.all(32),
            loop: false,
          ));

      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
