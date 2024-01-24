import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PlayerData {
  int currentScore;
  int highScore;
  int health;
  int level;

  PlayerData({
    this.currentScore = 0,
    this.highScore = 0,
    this.health = 100,
    this.level = 1,
  });

  void reset() {
    currentScore = 0;
    highScore = 0;
    health = 100;
    level = 1;
  }

  void increaseScore(int points) {
    currentScore += points;
    if (currentScore > highScore) {
      highScore = currentScore;
    }
  }

  void decreaseHealth(int damage) {
    health -= damage;
    if (health < 0) {
      health = 0;
    }
  }

  int getHealth() {
    return health;
  }

  int getHighScore() {
    return highScore;
  }

  int getLevel() {
    return level;
  }

  Future<void> exportDataToDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'player_data.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE player_data(id INTEGER PRIMARY KEY, current_score INTEGER, high_score INTEGER, health INTEGER, level INTEGER)',
        );
      },
      version: 1,
    );

    final data = {
      'current_score': currentScore,
      'high_score': highScore,
      'health': health,
      'level': level,
    };

    await database.insert('player_data', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await database.close();
  }

  Future<void> importDataFromDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'player_data.db'),
    );

    final result = await database.query('player_data', limit: 1);
    if (result.isNotEmpty) {
      final data = result.first;
      currentScore = data['current_score'] as int;
      highScore = data['high_score'] as int;
      health = data['health'] as int;
      level = data['level'] as int;
    }

    await database.close();
  }
}
