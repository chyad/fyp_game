import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';

class PowerupInfo {
  ItemDes itemDes;
  VoidCallback? itemFunction;

  int value;
  int cost;

  PowerupInfo({
    required this.itemDes,
    required this.itemFunction,
    this.value = 5,
    this.cost = 0,
  });
}

enum ItemDes {
  // heal
  heal(
    type: 'heal',
    baseValue: 5,
    descri: 'Bandage, heal HP : ',
    cost: 2,
    weight: 1,
  ),

  // player stats
  attack(
    type: 'attack',
    baseValue: 5,
    descri: 'Stats, increase attack : ',
    cost: 3,
    weight: 1,
  ),
  moveSpeed(
    type: 'moveSpeed',
    baseValue: 10,
    descri: 'Stats, increase moveSpeed : ',
    cost: 3,
    weight: 1,
  ),
  bulletSize(
    type: 'bulletSize',
    baseValue: 1,
    descri: 'Stats, increase bulletSize : ',
    cost: 3,
    weight: 1,
  ),
  bulletSpeed(
    type: 'bulletSpeed',
    baseValue: 10,
    descri: 'Stats, increase bulletSpeed : ',
    cost: 3,
    weight: 1,
  ),
  bulletRange(
    type: 'bulletRange',
    baseValue: 10,
    descri: 'Stats, increase  bulletRange : ',
    cost: 3,
    weight: 1,
  ),

  // random power up
  projectile(
    type: 'projectile',
    baseValue: 1,
    descri: 'projectile upgrade : ',
    cost: 10,
    weight: 1,
  ),

  // map reveal
  revealRoom(
    type: 'room',
    baseValue: 2,
    descri: 'Shattered Map Piece, locate map room : ',
    cost: 5,
    weight: 1,
  ),
  revealMap(
    type: 'map',
    baseValue: 1,
    descri: 'Blurry Map, reveal map : ',
    cost: 10,
    weight: 0.5,
  );

  final String type;
  final int baseValue;

  final String descri;

  final int cost;

  final double weight;

  const ItemDes({
    required this.type,
    required this.baseValue,
    required this.descri,
    required this.cost,
    required this.weight,
  });
}

void visibleMap(FypGame game) {
  for (var element in game.roomMapList) {
    element.visible = true;
  }
}

void visitedMap(FypGame game, int value) {
  List temp =
      game.roomMapList.where((element) => (element.visited == false)).toList();
  if (temp.isEmpty) {
    print('reveal done');
    return;
  }
  print(temp);
  for (var i = 0; i < value; i++) {
    final int randomIndex = Random().nextInt(temp.length);
    temp[randomIndex].visited = true;
    temp[randomIndex].visible = true;

    temp.removeAt(randomIndex);

    print('room revael $randomIndex ${game.roomMapList.length}');
    if (temp.isEmpty) {
      print('reveal done during for');
      break;
    }
  }
}

void healHp(FypGame game, double value) {
  game.player.updateHP(value);
}

void statsUp(FypGame game, double value, String type) {
  game.player.updateStats(value, type);
}

void projUp(FypGame game, double value, String type) {
  List<String> powerupList = [
    'reflect',
    'bullet_ring',
    'explosion',
    'black_hole',
    'mist',
    'triple_shot',
  ];

  List<String> temp =
      powerupList.toSet().difference(game.player.powerup.toSet()).toList();

  if (temp.isNotEmpty) {
    final int randomIndex = Random().nextInt(temp.length);
    String item = temp[randomIndex];

    game.player.powerup.add(item);
  }
}
