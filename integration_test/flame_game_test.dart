import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';

import 'package:fyp_game/game/entity/actor.dart';
import 'package:fyp_game/game/entity/area_effect.dart';
import 'package:fyp_game/game/entity/door.dart';
import 'package:fyp_game/game/entity/item.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/game.dart';

void main() {
  group('entity mount and remove', () {
    testWithGame<FypGame>(
      'obstacle mount and remove',
      FypGame.new,
      (game) async {
        print('add obst');
        final obstacle = Obstacle();
        game.add(obstacle);
        await game.ready();
        expect(obstacle.isMounted, true);

        expect(() => game.remove(obstacle), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

    testWithGame<FypGame>(
      'actor mount and remove',
      FypGame.new,
      (game) async {
        print('add actor');
        final actor = Actor();
        game.add(actor);
        await game.ready();
        expect(actor.isMounted, true);

        expect(() => game.remove(actor), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

    testWithGame<FypGame>(
      'gameplatform mount and remove',
      FypGame.new,
      (game) async {
        print('add gameplatform');
        final gameplatform = GamePlatform();
        game.add(gameplatform);
        await game.ready();
        expect(gameplatform.isMounted, true);

        expect(() => game.remove(gameplatform), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

    testWithGame<FypGame>(
      'door is loaded',
      FypGame.new,
      (game) async {
        print('add door');
        final door = Door();
        game.add(door);
        // no map is generated, door will be removed after loaded
        expect(door.isLoaded, true);
      },
    );

    testWithGame<FypGame>(
      'item mount and remove',
      FypGame.new,
      (game) async {
        print('add item');
        final item = Item();
        game.add(item);
        await game.ready();
        expect(item.isMounted, true);

        expect(() => game.remove(item), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

    testWithGame<FypGame>(
      'aoe mount and remove',
      FypGame.new,
      (game) async {
        print('add aoe');
        final aoe = AreaEffect();
        game.add(aoe);
        await game.ready();
        expect(aoe.isMounted, true);

        expect(() => game.remove(aoe), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

    testWithGame<FypGame>(
      'projectile mount and remove',
      FypGame.new,
      (game) async {
        print('add projectile');
        final projectile = Projectile(
            size: Vector2.all(16),
            direction: Vector2.zero(),
            shadowOffsetY: 0,
            position: Vector2.all(1),powerup:[]);
        game.add(projectile);
        await game.ready();
        expect(projectile.isMounted, true);

        expect(() => game.remove(projectile), returnsNormally);
        expect(() => game.update(0), returnsNormally);
      },
    );

  });

}
