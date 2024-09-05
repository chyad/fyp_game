import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/entity/projectile_function/enemy_projectile.dart';
import 'package:fyp_game/game/entity/static_entity/wall_border.dart';
import 'package:fyp_game/game/game.dart';

enum PlayerState { idle, running, dead, fall }

class Actor extends SpriteAnimationGroupComponent
    with ShadowOffset, SpriteData, HasGameRef<FypGame>, CollisionCallbacks {
  late String character;
  late double sizeOffset;
  //
  late double hp;
  late double attack;
  late double moveSpeed;
  late double bulletSize;
  late double bulletSpeed;
  late double bulletRange;
  //
  late double vision;

  Map status = {
    'hp': 100,
    'attack': 10,
    'moveSpeed': 150,
    //
    'bulletSize': 1,
    'bulletSpeed': 150,
    'bulletRange': 300,
  };

  Actor({
    super.position,
    super.anchor = Anchor.bottomCenter,
    super.children,
    super.size,
    //
    this.character = 'Mask Dude',
    this.sizeOffset = 1,
    //
    this.hp = 100,
    this.attack = 10,
    this.moveSpeed = 150,
    this.bulletSize = 1,
    this.bulletSpeed = 150,
    this.bulletRange = 300,
    //
    this.vision = 200,
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
    // debugMode = true;

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
      if (other is Actor || other is Obstacle || other is WallBorder) {
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
          // final separationDistanceY =
          //     (size.y / 2 * hitboxOffsetY) - collisionNormal.length;

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
          if (other is Obstacle && !other.unmovable) {
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

    if (this is Player) {
      if (isFalling) {
        playerState = PlayerState.fall;
      }
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
          stepTime: 0.15,
          textureSize: Vector2.all(96),
          loop: false,
        ));
    fallAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/Desappearing(96x96).png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.2,
          textureSize: Vector2.all(96),
          loop: false,
        ));

    // list of all ainmations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.dead: removeAnimation,
      PlayerState.fall: fallAnimation,
    };

    // set current animation
    current = PlayerState.idle;
  }
}
