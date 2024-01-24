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
  Apple,
  Bananas,
  Kiwi,
}

class Item extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  List<Fruit> fruits = Fruit.values;

  Images images;

  Item({
    super.position,
    super.anchor = Anchor.center,
    required this.images,
    Vector2? size,
    Vector2? scale,
    double? angle,
    super.priority = 10000,
  }) : super(
          size: Vector2.all(32),
        );

  String itemType = '';

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;

    final int randomIndex = Random().nextInt(fruits.length);
    final Fruit randomFruit = fruits[randomIndex];

    itemType = randomFruit.name;

    animation = SpriteAnimation.fromFrameData(
        images.fromCache('Items/Fruits/${randomFruit.name}.png'),
        SpriteAnimationData.sequenced(
          amount: 17,
          stepTime: .05,
          textureSize: Vector2.all(32),
        ));

    print('1 :$itemType');
    print('Items/Fruits/${randomFruit.name}.png');

    add(CircleHitbox(
      anchor: Anchor.center,
      position: Vector2(width / 2, height / 2),
      radius: (height / 2 * 0.5),
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

      animation = SpriteAnimation.fromFrameData(
          images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.05,
            textureSize: Vector2.all(32),
            loop: false,
          ));

      // size = Vector2.all(48);

      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );

      // data ...
      // item count ++ etc
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
