import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/game.dart';

enum PlayerState { idle, running, dead, testse }

class Actor extends SpriteAnimationGroupComponent
    with ShadowOffset, SpriteData, HasGameRef<FypGame>, CollisionCallbacks {
  late String character;
  //
  late double hp;
  late double sizeOffset;
  late double moveSpeed;
  late double bulletSize;
  late double bulletSpeed;
  //
  late double vision;

  Map status = {
    'hp': 10,
    'sizeOffset': 1,
    'moveSpeed': 100,
    'bulletSize': 1,
    'bulletSpeed': 150,
  };

  Actor({
    super.position,
    super.anchor = Anchor.bottomCenter,
    super.children,
    super.size,
    //
    this.character = 'Mask Dude',
    //
    this.hp = 10,
    this.sizeOffset = 1,
    this.moveSpeed = 100,
    this.bulletSize = 16,
    this.bulletSpeed = 150,
    //
    this.vision = 250,
  });

  Vector2 velocity = Vector2.zero();

  // platform
  final double gravity = 9.8;
  int touchingGround = 0;
  bool isFalling = false;
  Vector2 lastPosition = Vector2.zero();
  // jump part, ignore for now
  // final double _jumpForce = 1000;
  final double terminalVelocity = 30;
  // bool hasJumped = false;
  // bool isOnGround = true;

  late SpriteComponent shadow;

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;

    lastPosition = position.clone();

    size.clamp(
        (this is Enemy) ? Vector2.all(32) : Vector2.all(16), Vector2.all(128));

    shadow = addShadow(game);
    await addAll([addHitbox(), shadow]);

    // paint.blendMode = BlendMode.dst;
    // shadow.paint.blendMode = BlendMode.srcATop;

    loadAllAnimatinos();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updatePlayerState();

    if (!isFalling) {
      priority = (position.y + height / 2).floor();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!(hp <= 0 && isFalling)) {
      if (other is Actor || other is Obstacle) {
        // copy from internet, may modify later
        // print(other);
        if (intersectionPoints.length == 2) {
          final mid = (intersectionPoints.elementAt(0) +
                  intersectionPoints.elementAt(1)) /
              2;

          final collisionNormal = absoluteCenter -
              mid +
              Vector2(0, (positionOffset.y / 2 - 0.5) * height);
          final separationDistanceX =
              (size.x.clamp(hitboxMin, hitboxMax) / 2 * hitboxOffsetX) -
                  collisionNormal.length;
          final separationDistanceY =
              (size.y / 2 * hitboxOffsetY) - collisionNormal.length;

          collisionNormal.normalize();

          // If collision normal is almost upwards,
          // player must be on ground.

          // Resolve collision by moving player along
          // collision normal by separation distance.
          // print(collisionNormal.scaled(separationDistance));

          // move player pos

          position += collisionNormal.scaled(separationDistanceX);

          // polygon use
          // position += Vector2(collisionNormal.x * separationDistanceX,
          //     collisionNormal.y * separationDistanceY);

          // move obs pos
          if (other is Obstacle && !other.isBorder) {
            other.position -= collisionNormal.scaled(separationDistanceX);
          }
        }
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  SpriteAnimation spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0 || velocity.y > 0 || velocity.y < 0) {
      playerState = PlayerState.running;
    }

    if (hp <= 0 && this is! Player) {
      playerState = PlayerState.dead;
      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.2),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );
    }

    current = playerState;
  }

  void loadAllAnimatinos() {
    idleAnimation = spriteAnimation('Idle', 11);
    runAnimation = spriteAnimation('Run', 12);

    removeAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/Desappearing(96x96).png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.1,
          textureSize: Vector2.all(96),
          loop: false,
        ));

    // list of all ainmations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.dead: removeAnimation,
    };

    // set current animation
    current = PlayerState.idle;
  }
}
