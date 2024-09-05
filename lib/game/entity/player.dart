import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/function_mapping/cd.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';
import 'package:fyp_game/game/hud/audio_component.dart';
import 'package:fyp_game/game/overlay/game_over_menu.dart';
import 'package:provider/provider.dart';

import 'package:fyp_game/game/entity/projectile_function/enemy_projectile.dart';

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

CDTimer actionsTimer = CDTimer();

class Player extends Actor with KeyboardHandler {
  Player({
    super.position,
    super.anchor,
    super.children,
    super.size,
    //
    super.character = 'Ninja Frog',
    super.hp = 100,
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
  double attackCD = 0.15;

  double invicTimer = 0;
  double invicCD = 0.8;
  bool invicible = false;

  double fallTimer = 0;
  double updatetimer = 10;

  // keyboard value
  double horizontalMovement = 0;
  double verticalMovement = 0;
  Vector2 lastFacingDirection = Vector2(1, 0);

  double moveSpeedAdjust = 1;

  int money = 0;
  List<String> powerup = [];

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

    // update hud hp bar etc

    actionsTimer.initBehavior();
    actionsTimer.resetTimer(Behavior.jump);

    print('cd_temp: ${actionsTimer.cds}');

    size = Vector2.all(32);
    size *= sizeOffset;

    size.clamp(Vector2.all(16), Vector2.all(128));
    print(hp);

    status['hp'] = hp;
    print(status);

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

    // hand = SpriteComponent(
    //   sprite: Sprite(
    //     game.images.fromCache('Main Characters/$character/Fall (32x32).png'),
    //     srcSize: Vector2.all(32),
    //     srcPosition: Vector2(32 * 0, 0), // 0 to 6
    //   ),
    //   size: Vector2.all(16),
    //   position: Vector2(0, height / 2), // width -> 0 item is on back
    //   anchor: Anchor.center,
    // );

    // await addAll([hat, hand]);

    add(hat);

    playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);

    if (game.newGame) {
      reset();
      game.newGame = false;
    }

    setData(playerData);

    updateHP(0);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // dt /= 4;
    // deathCheck();
    _updatePlayerMovement(dt);

    if (touchingGround <= 0 && actionsTimer.isReady(Behavior.jump, 2)) {
      print('fall');
      priority = -1;
      isFalling = true;
      timer = 0;
      moveSpeedAdjust = 0.1;
    } else {}

    if (touchingGround > 0 &&
        !isFalling &&
        actionsTimer.isReady(Behavior.updateLastPosition, 1)) {
      // update last pos, reset timer
      lastPosition = position.clone();
      actionsTimer.resetTimer(Behavior.updateLastPosition);
    }

    if (isFalling) {
      actionsTimer.resetTimer(Behavior.updateLastPosition);
      // maybe try size effect to simulate falling
      // position.y += gravity * 3 * dt;
      fallTimer += dt;

      if (fallTimer >= 1.5) {
        updateHP(-50);
        moveSpeedAdjust = 1;
        fallTimer = 0;
        position = lastPosition;
        isFalling = false;
      }

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

    if (game.joystickAttack.isDragged &&
        actionsTimer.isReady(Behavior.attack, attackCD)) {
      projectileAttack();
      actionsTimer.resetTimer(Behavior.attack);
    }

    if (invicTimer > invicCD && invicible) {
      print('invic, $invicTimer, $dt');
      invicible = false;
      invicTimer = 0;
    }

    timer += dt;
    updatetimer += dt;
    invicTimer += dt;

    actionsTimer.updateTime(dt);

    // print('cd_temp: ${actionsTimer.cds}');

    // for update sprite state

    // movement
    position.add(velocity * moveSpeed * dt * moveSpeedAdjust);
    super.update(dt);
  }

  void _updatePlayerMovement(double dt) {
    // if (hasJumped && isOnGround) {
    //   _playerJump(dt);
    // }
    velocity.x = horizontalMovement;
    velocity.y = verticalMovement;

    position += velocity * moveSpeed * dt * moveSpeedAdjust;
  }

  void projectileAttack() {
    // Future.delayed(const Duration(milliseconds: 10), () {
    game.audio.playSfx('laserShoot.wav');

    Projectile projectile = Projectile(
      size: Vector2.all(24 * bulletSize),
      position: position.clone() -
          Vector2(0, (size.x.clamp(hitboxMin, hitboxMax / 2) / 2)),
      direction: game.joystickAttack.isDragged
          ? game.joystickAttack.delta
          : lastFacingDirection,
      shadowOffsetY: size.x.clamp(hitboxMin, hitboxMax / 2) / 2,
      speed: bulletSpeed,
      range: bulletRange,
      powerup: powerup,

      //(positionOffset.y * height / 2) / 2 - (bulletSize / 2),

      // can add to player by ( add(component); ). maybe extra body part / costume / obital shielf and weapon
      // position: Vector2.all(16),
    );

    game.cam.world!.add(projectile);

    // updateHP(-30);
    // add(projectile);

    // problem : world coord 0,0 at center
    // world get deleted affter remove from parent

    // camera at top left
    // and layer to fix

    // add(projectile);
    // }
    // );
  }

  void reset() {
    playerData.character = 'Ninja Frog';
    playerData.sizeOffset = 1;

    playerData.hp = 100;
    playerData.attack = 10;
    playerData.moveSpeed = 150;

    playerData.bulletSize = 1;
    playerData.bulletSpeed = 150;
    playerData.bulletRange = 400;

    playerData.money = 0;
    playerData.powerup = [];

    playerData.save();
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
    sizeOffset = 1;

    hp = playerData.hp;
    attack = playerData.attack;
    moveSpeed = playerData.moveSpeed;

    bulletSize = playerData.bulletSize;
    bulletSpeed = playerData.bulletSpeed;
    bulletRange = playerData.bulletRange;

    money = playerData.money;
    powerup = playerData.powerup;

    status['hp'] = hp;

    status['attack'] = attack;
    status['moveSpeed'] = moveSpeed;
    //
    status['bulletSize'] = bulletSize;
    status['bulletSpeed'] = bulletSpeed;
    status['bulletRange'] = bulletRange;

    // item etc
  }

  void savePlayerHive() {
    playerData.character = 'Ninja Frog';
    playerData.sizeOffset = 1.0;

    playerData.hp = double.parse(hp.toStringAsFixed(0));
    ;
    playerData.attack = attack;
    playerData.moveSpeed = moveSpeed;

    playerData.bulletSize = double.parse(bulletSize.toStringAsFixed(1));
    playerData.bulletSpeed = bulletSpeed;
    playerData.bulletRange = bulletRange;

    playerData.money = money;
    playerData.powerup = powerup;

    print('save player stats : ${playerData}');

    playerData.save();
  }

  void updateHiveData() {
    playerData.hp = hp;
    playerData.sizeOffset = sizeOffset;

    print('hive save player data');

    playerData.save();
    // hp
  }

  void updateHP(double value) {
    if (value < 0) {
      game.audio.playSfx('hitHurt.wav');
    }
    if (value > 0) {
      game.audio.playSfx('heal.wav');
    }
    hp += value;
    hp = double.parse(hp.toStringAsFixed(0));
    hp = hp.clamp(0, 100);
    status['hp'] = hp;

    // notifier for hud update
    game.updateData.value += 1;
  }

  void updateStats(double value, String type) {
    switch (type) {
      case 'attack':
        attack += value;
        status['attack'] = attack;
        break;
      case 'moveSpeed':
        moveSpeed += value;
        moveSpeed = moveSpeed.clamp(150, 400);
        status['moveSpeed'] = moveSpeed;
        break;
      case 'bulletSize':
        bulletSize += double.parse(value.toStringAsFixed(1));
        status['bulletSize'] = bulletSize;
        break;
      case 'bulletSpeed':
        bulletSpeed += value;
        status['bulletSpeed'] = bulletSpeed;
        break;
      case 'bulletRange':
        bulletRange += value;
        status['bulletRange'] = bulletRange;
        break;
      default:
    }
  }

  void deathCheck() {
    if (hp <= 0) {
      print('death message');
      game.pauseEngine();
      game.overlays.add(GameOverMenu.id);
    }
  }
}
