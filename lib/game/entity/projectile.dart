import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame/image_composition.dart';

import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/mixin.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/entity/projectile_function/enemy_projectile.dart';
import 'package:fyp_game/game/entity/static_entity/wall_border.dart';
import 'package:fyp_game/game/game.dart';

class Projectile extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FypGame> {
  late Vector2 direction;
  late double shadowOffsetY;

// Speed of the bullet. // pass from data later
  late double speed;
  late double range;
  late bool notSplit;
  late bool isPlayer;
  Projectile({
    super.priority = 10000,
    super.position,
    this.notSplit = true,
    super.anchor = Anchor.center,
    required super.size,
    required this.direction,
    required this.shadowOffsetY,
    //
    this.speed = 150,
    this.range = 300,
    this.isPlayer = true,
    this.damage = 1,
    required this.powerup,
  });

  List<String> powerup = [];

  double damage;

  double hitboxOffsetX = 0.6;
  double spawnTimer = 0;
  double travelDistance = 0;

  Vector2 velocity = Vector2.zero();
  late SpriteComponent shade;

  bool collide = false;

  @override
  void onMount() {
    // debugMode = true;

    // animation = sprite;

    if (direction == Vector2.all(0)) {
      // fix to facing direction later
      direction = Vector2(1, 0);
    } else {
      // fix to unit vector
      // might use another joystick delta for attack
      direction = direction / sqrt(direction.dot(direction));
    }
    final shape = CircleHitbox(
      anchor: Anchor.center,
      position: Vector2(width / 2, height / 2 + shadowOffsetY),
      radius: (height / 2 * hitboxOffsetX),
      isSolid: true,
    );

    String img = isPlayer ? 'player' : 'enemy';

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/${img}Bullet.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(32),
      ),
    );

    shade = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache('HUD/Joystick.png'),
      ),
      size: Vector2(size.x * hitboxOffsetX, size.y / 4),
      position: Vector2(width / 2, height / 2 + shadowOffsetY),
      anchor: Anchor.center,
      priority: 1,
    );
    add(shade);

    add(shape);

    if (powerup.contains('multiShot')) {
      List<Projectile> test = multiShot(this, 3);
      game.cam.world!.addAll(test);
    }

    super.onMount();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    bool ready = notSplit || spawnTimer >= 0.1;

    if (ready) {
      if (other is Obstacle || other is WallBorder) {
        // splitProj();

        if (other is Obstacle && !other.unmovable) {
          other.hp -= 1;
          if (other.hp <= 0) {
            other.removeFromParent();
          }
        }

        if (powerup.contains('reflect')) {
          if (intersectionPoints.length == 2) {
            print('proj reflect');
            reflectProj2(intersectionPoints);
          }
        } else {
          collide = true;
        }
      }
    }
    if (other is Enemy && isPlayer) {
      other.hp -= game.player.attack;
      other.vision += 100;
      collide = true;
    }

    if (other is Player && !isPlayer) {
      if (!other.invicible) {
        // other.position += (other.position - position).normalized() *
        //     5; // to be tune , or add stats for enemy
        other.invicible = true;
        other.updateHP(-2);
      }
      collide = true;
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    // direction = (direction + velocity) /
    //     sqrt((direction + velocity).dot(direction + velocity));

    Vector2 move = ((direction) * speed) * dt + velocity * dt;

    position += ((direction) * speed) * dt + velocity * dt;
    // shade.position += ((direction) * speed) * dt + velocity * dt;

    spawnTimer += dt;
    travelDistance += sqrt(pow(move.x, 2) + pow(move.y, 2));
    // print('travelDistance $travelDistance');

    // test
    if (travelDistance >= range || spawnTimer >= 10 || collide) {
      // print('travelDistance >= range');
      removeAnimation();
    }

    super.update(dt);
  }

  void removeAnimation() {
    speed *= 0.2;
    speed.clamp(1, 100);

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/Desappearing(96x96).png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.1,
          textureSize: Vector2.all(96),
          loop: false,
        ));

    add(
      OpacityEffect.fadeOut(
        LinearEffectController(0.1),
        onComplete: () {
          add(RemoveEffect());
        },
      ),
    );
  }

  @override
  void onRemove() {
    powerup.forEach((element) {
      double odd = isPlayer ? Random().nextDouble() : 1;
      if (odd > 0.5) {
        switch (element) {
          case 'ring':
            Projectile temp = Projectile(
                position: position,
                size: Vector2.all(16),
                direction: Vector2.random().normalized(),
                shadowOffsetY: size.x.clamp(8, 64 / 2) / 2,
                powerup: [],
                isPlayer: isPlayer);
            game.cam.world!.addAll(allAngleProj(temp, 6));
            break;
          case 'explosion':
            game.cam.world!.add(spawnExplosion(this));
            break;
          case 'blackhole':
            game.cam.world!.add(spawnBlackhole(this));
            break;
          case 'mist':
            game.cam.world!.add(spawnDamageArea(this));
            break;
          default:
        }
      }
    });

    super.onRemove();
  }

  void reflectProj(Set<Vector2> intersectionPoints) {
    final mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
    final collisionNormal = (position + Vector2(0, shadowOffsetY)) - mid;
    // collisionNormal.normalize();

    Projectile split = Projectile(
      position: position.clone(),
      notSplit: false,
      size: size,
      direction: direction.reflected(collisionNormal.normalized()),
      shadowOffsetY: shadowOffsetY,
      powerup: [],
    );

    game.cam.world!.add(split);
  }

  void reflectProj2(Set<Vector2> intersectionPoints) {
    final mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
    final collisionNormal = (position + Vector2(0, shadowOffsetY)) - mid;
    // collisionNormal.normalize();
    direction = direction.reflected(collisionNormal.normalized()).normalized();
  }

  void splitProj() {
    if (notSplit) {
      notSplit = false;
      double vectX = direction.x;
      double vectY = direction.y;

      Vector2 tempV = -direction.clone();

      Vector2 spread = Vector2.zero();

      Random random = Random();

      for (int i = 0; i < 2; i++) {
        int dir = random.nextBool() ? 1 : -1;
        double angle = random.nextDouble() * 45 / 2;
        spread = rotateDeg(tempV.clone(), dir * angle);

        Projectile split = Projectile(
          position: position.clone(),
          notSplit: false,
          size: size,
          direction: spread,
          shadowOffsetY: shadowOffsetY,
          powerup: [],
        );
        game.cam.world!.add(split);

        // // rotate 90d
        // double temp = tempV.x;
        // tempV.x = -tempV.y;
        // tempV.y = temp;
      }
    }
  }

  Vector2 rotateDeg(Vector2 v, double degrees) {
    double theta = radians(degrees);
    double sinn = sin(theta);
    double coss = cos(theta);

    double tx = v.x;
    double ty = v.y;
    v.x = (coss * tx) - (sinn * ty);
    v.y = (sinn * tx) + (coss * ty);
    return v;
  }
}
