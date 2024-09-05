import 'dart:math';

import 'package:flame/components.dart';
import 'package:fyp_game/game/entity/area_effect.dart';
import 'package:fyp_game/game/entity/item.dart';
import 'package:fyp_game/game/entity/projectile.dart';

List<Projectile> allAngleProj(Projectile proj, int count) {
  List<Projectile> temp = [];

  Vector2 spread = Vector2.zero();
  Vector2 tempV = proj.direction.clone();

  double angle = 360 / count;

  for (int i = 0; i < count; i++) {
    spread = rotateDeg(tempV.clone(), angle * i);

    final Projectile bullet = Projectile(
      position: proj.position.clone(),
      notSplit: false,
      size: proj.size,
      direction: spread,
      shadowOffsetY: proj.shadowOffsetY,
      isPlayer: proj.isPlayer,
      powerup: [],
    );

    temp.add(bullet);
  }

  return temp;
}

List<Projectile> multiShot(Projectile proj, int count) {
  List<Projectile> projList = [];

  Vector2 spread = Vector2.zero();
  Vector2 tempV = proj.direction.clone();

  int maxSpread = count * 15;
  maxSpread = maxSpread.clamp(0, 270);

  Random random = Random();

  for (int i = 0; i < count; i++) {
    int dir = random.nextBool() ? 1 : -1;
    double angle = random.nextDouble() * maxSpread / 2;
    spread = rotateDeg(tempV.clone(), dir * angle);

    Projectile split = Projectile(
      position: proj.position.clone(),
      notSplit: true,
      size: proj.size,
      direction: spread,
      shadowOffsetY: proj.shadowOffsetY,
      isPlayer: proj.isPlayer,
      powerup: [],
    );
    print('Split $tempV');

    projList.add(split);
  }

  return projList;
}

List<Projectile> splitProj(Projectile proj, int count) {
  List<Projectile> projList = [];
  if (proj.notSplit) {
    proj.notSplit = false;
    double vectX = proj.direction.x;
    double vectY = proj.direction.y;

    Vector2 tempV = -proj.direction.clone();

    Vector2 spread = Vector2.zero();

    Random random = Random();

    for (int i = 0; i < count; i++) {
      int dir = random.nextBool() ? 1 : -1;
      double angle = random.nextDouble() * 45 / 2;
      spread = rotateDeg(tempV.clone(), dir * angle);

      Projectile split = Projectile(
        position: proj.position.clone(),
        notSplit: false,
        size: proj.size,
        direction: spread,
        shadowOffsetY: proj.shadowOffsetY,
        powerup: [],
      );
      print('Split $tempV');

      projList.add(split);
    }
  }
  return projList;
}

// helper

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

Item spawnCoins(PositionComponent e) {
  return Item(
    position: e.position,
  );
}

AreaEffect spawnExplosion(PositionComponent e) {
  return AreaEffect(
    position: e.position,
    type: 'Explosion',
    size: e.size * 1.5,
    damage: 5,
  );
}

AreaEffect spawnBlackhole(PositionComponent e) {
  return AreaEffect(
    position: e.position,
    type: 'BlackHole',
    size: e.size * 4,
  );
}

AreaEffect spawnDamageArea(PositionComponent e) {
  return AreaEffect(
    position: e.position,
    type: 'Mist',
    size: e.size * 3,
  );
}

AreaEffect spawnAoe(PositionComponent e, String aoeType) {
  final random = Random();

  double sizeAdjust = random.nextDouble() * 1 + 0.5;
  double damage = 1;

  switch (aoeType) {
    case 'Explosion':
      sizeAdjust = random.nextDouble() * 1 + 0.5;
      damage = (e.size.x * 0.5).clamp(10, 30);
      break;
    case 'BlackHole':
      sizeAdjust = random.nextDouble() * 1.5 + 1;
      damage = (e.size.x * 0.5).clamp(10, 30);
      break;

    case 'Mist':
      sizeAdjust = random.nextDouble() * 2 + 1;
      damage = (e.size.x * 0.5).clamp(5, 10);
      break;

    default:
  }

  return AreaEffect(
    position: e.position,
    type: aoeType,
    size: e.size * sizeAdjust,
    damage: damage,
  );
}
