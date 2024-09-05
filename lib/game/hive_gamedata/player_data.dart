import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'player_data.g.dart';

// This class represents all the persistent data that we
// might want to store for tracking player progress.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  static const String playerDataBox = 'PlayerData11Box';
  static const String playerDataKey = 'PlayerData11';

  // The spaceship type of player's current spaceship.
  @HiveField(0)
  String character;

  @HiveField(1)
  double hp;

  @HiveField(10)
  double attack;

  @HiveField(2)
  double sizeOffset;

  @HiveField(3)
  double moveSpeed;

  @HiveField(4)
  double bulletSize;

  @HiveField(5)
  double bulletSpeed;

  @HiveField(9)
  double bulletRange;

  @HiveField(6)
  List<String> powerup;

  // Highest player score so far.
  @HiveField(7)
  late int _highScore;
  int get highScore => _highScore;

  // Balance money.
  @HiveField(8)
  int money;

  // Keeps track of current score.
  // If game is not running, this will
  // represent score of last round.
  int _currentScore = 0;

  int get currentScore => _currentScore;

  set currentScore(int newScore) {
    _currentScore = newScore;
    // While setting currentScore to a new value
    // also make sure to update highScore.
    if (_highScore < _currentScore) {
      _highScore = _currentScore;
    }
  }

  PlayerData({
    required this.character,
    required this.hp,
    required this.attack,
    required this.sizeOffset,
    required this.moveSpeed,
    //
    required this.bulletSize,
    required this.bulletSpeed,
    required this.bulletRange,
    //
    required this.powerup,
    int highScore = 0,
    required this.money,
  }) {
    _highScore = highScore;
  }

  /// Creates a new instance of [PlayerData] from given map.
  PlayerData.fromMap(Map<String, dynamic> map)
      : character = map['charater'],
        sizeOffset = map['sizeOffset'],
        //
        hp = map['hp'],
        attack = map['attack'],
        moveSpeed = map['moveSpeed'],
        //
        bulletSize = map['bulletSize'],
        bulletSpeed = map['bulletSpeed'],
        bulletRange = map['bulletRange'],
        //
        powerup = [],
        _highScore = map['highScore'],
        money = map['money'];

  // A default map which should be used for creating the
  // very first PlayerData instance when game is launched
  // for the first time.
  static Map<String, dynamic> defaultData = {
    'charater': 'Ninja Frog',
    'sizeOffset': 1.0,
    //
    'hp': 100.0,
    'attack': 10.0,
    'moveSpeed': 200.0,
    //
    'bulletSize': 1.0,
    'bulletSpeed': 150.0,
    'bulletRange': 400.0,
    //
    'item': [],
    'highScore': 0,
    'money': 0,
  };

  // /// Returns true if given [SpaceshipType] is owned by player.
  // bool isOwned(Item spaceshipType) {
  //   return Item.contains(spaceshipType);
  // }

  // /// Returns true if player has enough money to by given [SpaceshipType].
  // bool canBuy(SpaceshipType spaceshipType) {
  //   return (money >= Spaceship.getSpaceshipByType(spaceshipType).cost);
  // }

  // /// Returns true if player's current spaceship type is same as given [SpaceshipType].
  // bool isEquipped(SpaceshipType spaceshipType) {
  //   return (this.spaceshipType == spaceshipType);
  // }

  // /// Buys the given [SpaceshipType] if player has enough money and does not already own it.
  // void buy(SpaceshipType spaceshipType) {
  //   if (canBuy(spaceshipType) && (!isOwned(spaceshipType))) {
  //     money -= Spaceship.getSpaceshipByType(spaceshipType).cost;
  //     ownedSpaceships.add(spaceshipType);
  //     notifyListeners();

  //     // Saves player data to disk.
  //     save();
  //   }
  // }

  // /// Sets the given [SpaceshipType] as the current spaceship type for player.
  // void equip(SpaceshipType spaceshipType) {
  //   this.spaceshipType = spaceshipType;
  //   notifyListeners();

  //   // Saves player data to disk.
  //   save();
  // }
}

@HiveType(typeId: 1)
enum ItemType {
  @HiveField(0)
  Apple,

  @HiveField(1)
  Bananas,

  @HiveField(2)
  Kiwi,
}
