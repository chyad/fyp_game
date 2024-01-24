import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';
import 'package:provider/provider.dart';

enum CDs {
  attack(
    cd: 0.3,
  ),
  fell(
    cd: 0.3,
  ),
  invicible(
    cd: 0.3,
  );

  final double cd;

  const CDs({
    required this.cd,
  });
}

class Player extends Actor with KeyboardHandler {
  Player({
    super.position,
    super.anchor,
    super.children,
    super.size,
    //
    super.character = 'Ninja Frog',
    super.hp = 100,
    super.sizeOffset = 1,
    //
    super.bulletSize = 16,
    super.bulletSpeed,
  });

  late PlayerData playerData;
  int get score => playerData.currentScore;

  late SpriteComponent hand;
  late SpriteComponent hat;

  // spinning use, no use for now
  Vector2 get forward => Vector2(0, -1)..rotate(angle);
  double angularSpeed = 2;

  // CDs
  double timer = 0;
  double attackCD = 0.05;

  double invicTimer = 0;
  double invicCD = 0.8;
  bool invicible = false;

  double fallTimer = 0;
  double updatetimer = 10;

  // keyboard value
  double horizontalMovement = 0;
  double verticalMovement = 0;
  Vector2 lastFacingDirection = Vector2(1, 0);

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

    size *= sizeOffset;
    size.clamp(Vector2.all(16), Vector2.all(128));
    print(hp);

    // lastPosition = position;

    // cusmetic, condition then load things add things.
    hat = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('Main Characters/$character/Idle (32x32).png'),
        srcSize: Vector2.all(32),
        srcPosition: Vector2(32 * 0, 0), // 0 to 6
      ),
      size: size / 2,
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.center,
    );

    hand = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('Main Characters/$character/Fall (32x32).png'),
        srcSize: Vector2.all(32),
        srcPosition: Vector2(32 * 0, 0), // 0 to 6
      ),
      size: Vector2.all(16),
      position: Vector2(0, height / 2), // width -> 0 item is on back
      anchor: Anchor.center,
    );

    // await addAll([hat, hand]);

    add(hat);

    playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // dt /= 4;

    _updatePlayerMovement(dt);

    if (touchingGround <= 0 && timer > 0.5) {
      priority = -1;
      // isFalling = true;
      timer = 0;
    } else {}

    if (touchingGround > 0 && !isFalling && updatetimer >= 3) {
      lastPosition = position.clone();
      updatetimer = 0;
      print('pos update $lastPosition');
    }

    if (isFalling) {
      updatetimer = 0;
      position.y += gravity * terminalVelocity * dt;
      if (fallTimer >= 1.5) {
        hp -= 5;
        fallTimer = 0;
        position = lastPosition;
        isFalling = false;
      }
      fallTimer += dt;
      // print(' falling $position, $lastPosition');
    }

    // maybe for swim or features
    if (game.joystickMovement.isDragged) {
      // silly thing, spinning
      // hat.angle += lerpDouble(
      //     0,
      //     forward.angleToSigned(game.joystickMovement.delta),
      //     angularSpeed * dt)!;

      velocity = game.joystickMovement.relativeDelta;
      // lastFacingDirection = game.joystickMovement.relativeDelta;
    } else {
      angle = 0;
    }

    if (game.joystickAttack.isDragged && timer > attackCD) {
      projectileAttack();

      // cool down
      timer = 0;
    }

    if (invicTimer > invicCD && invicible) {
      print('invic, $invicTimer, $dt');
      invicible = false;
      invicTimer = 0;
    }

    timer += dt;
    updatetimer += dt;
    invicTimer += dt;

    // for update sprite state

    // movement
    position.add(velocity * moveSpeed * dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    verticalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    final attackKey = keysPressed.contains(LogicalKeyboardKey.keyZ);

    if (attackKey && timer > attackCD) {
      projectileAttack();
      addToScore(1);
      timer = 0;
    }

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    verticalMovement += isUpKeyPressed ? -1 : 0;
    verticalMovement += isDownKeyPressed ? 1 : 0;

    if (horizontalMovement != 0 || verticalMovement != 0) {
      lastFacingDirection = Vector2(horizontalMovement, verticalMovement);
    }

    // hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    // if (hasJumped && isOnGround) {
    //   _playerJump(dt);
    // }
    velocity.x = horizontalMovement;
    velocity.y = verticalMovement;

    position += velocity * moveSpeed * dt;
  }

  void projectileAttack() {
    Projectile projectile = Projectile(
      game.images.fromCache('Items/Fruits/Apple.png'),
      size: Vector2.all(16 * bulletSize),
      position: position.clone() -
          Vector2(0, (size.x.clamp(hitboxMin, hitboxMax / 2) / 2)),
      direction: game.joystickAttack.isDragged
          ? game.joystickAttack.delta
          : lastFacingDirection,
      shadowOffsetY: size.x.clamp(hitboxMin, hitboxMax / 2) /
          2, //(positionOffset.y * height / 2) / 2 - (bulletSize / 2),

      // can add to player by ( add(component); ). maybe extra body part / costume / obital shielf and weapon
      // position: Vector2.all(16),
    );

    game.cam.world!.add(projectile);
    // add(projectile);

    // problem : world coord 0,0 at center
    // world get deleted affter remove from parent

    // camera at top left
    // and layer to fix

    // add(projectile);
  }

  void reset() {
    playerData.character = 'Ninja Frog';

    playerData.hp = 10;
    playerData.sizeOffset = 1;
    playerData.moveSpeed = 100;

    playerData.bulletSize = 1;
    playerData.bulletSpeed = 150;
  }

  void addToScore(int points) {
    playerData.currentScore += points;
    playerData.money += points;

    print('money: ${playerData.money}');

    // Saves player data to disk.
    playerData.save();
  }

  void setData(PlayerData playerData) {
    character = playerData.character;

    hp = playerData.hp;
    sizeOffset = playerData.sizeOffset;

    moveSpeed = playerData.moveSpeed;

    bulletSize = playerData.bulletSize;
    bulletSpeed = playerData.bulletSpeed;

    // item etc
  }

  void updateData() {
    game.updateData.value += 1;

    playerData.hp = hp;
    playerData.sizeOffset = sizeOffset;

    playerData.save();
    // hp
  }
}
