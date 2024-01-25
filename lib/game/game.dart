import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/entity/door.dart';
import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/item.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';

import 'package:fyp_game/game/hud/hud.dart';
import 'package:fyp_game/game/room/generateRoom.dart';
import 'package:fyp_game/game/room/map.dart';
import 'package:fyp_game/game/room/renderRoom.dart';

import 'package:fyp_game/game/room/room.dart';
import 'package:provider/provider.dart';

class FypGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final fixedResolution = Vector2(640, 320);

  Room? currentRoom;

  AddRoom? room;

  late Player player;

  late PlayerData playerData;

  @override
  Color backgroundColor() => Colors.teal.shade50;

  final linkedList = LinkedList<TiledComponent>();

  final updateData = ValueNotifier<int>(0);

  final hud = Hud(priority: 1);
  late final CameraComponent cam = CameraComponent.withFixedResolution(
    width: fixedResolution.x,
    height: fixedResolution.y,
    hudComponents: [
      hud,
      joystickMovement,
      joystickAttack,
    ],
  );

  late final JoystickComponent joystickMovement = JoystickComponent(
    knob: SpriteComponent(
      sprite: Sprite(
        images.fromCache('HUD/Knob.png'),
      ),
    ),
    background: SpriteComponent(
      sprite: Sprite(
        images.fromCache('HUD/Joystick.png'),
      ),
    ),
    position: Vector2(80, fixedResolution.y - 80),
    priority: 1,
  );

  late final JoystickComponent joystickAttack = JoystickComponent(
    knob: SpriteComponent(
      sprite: Sprite(
        images.fromCache('HUD/Knob.png'),
      ),
    ),
    background: SpriteComponent(
      sprite: Sprite(
        images.fromCache('HUD/Joystick.png'),
      ),
    ),
    position: Vector2(fixedResolution.x - 80, fixedResolution.y - 80),
    priority: 1,
  );

  late TiledComponent map;
  List<PositionComponent> entityList = [];

  @override
  FutureOr<void> onLoad() async {
    print('game on load');
    await images.loadAllImages();

    add(cam);

    return super.onLoad();
  }

  @override
  void onAttach() async {
    // loadRoom('room_02');

    print('game attach');
    entityList = [];

    player = Player(position: Vector2.all(10));
    entityList.add(player);

    print('this $entityList');

    map = await TiledComponent.load('room_02.tmx', Vector2.all(16));

    randMap(map, this, entityList);
    spawnDoor(map);
    setupCamera(map);
    room = AddRoom(room: map, entityList: entityList);

    cam.world = room;

    await add(room!);

    print('game on attach');
    if (buildContext != null) {
      // Get the PlayerData from current build context without registering a listener.
      playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      // Update the current spaceship type of player.
      // _player.setSpaceshipType(playerData.spaceshipType);
    }
    // _audioPlayerComponent.playBgm('9. Space Invaders.wav');
    super.onAttach();
  }

  void loadRoom(String roomName) async {
    currentRoom?.removeFromParent();
    currentRoom = Room(
      roomName:
          roomName, // make another one passing tile component and entity etc
    );
    print('loading room');
    print(children.whereType<Room>());

    cam.world = currentRoom;

    await add(currentRoom!);
  }

  void loadRoom2() async {
    room?.removeFromParent();
    entityList = [];

    print(children.whereType<AddRoom>());

    player = Player(position: Vector2.all(10));
    entityList.add(player);

    map = await TiledComponent.load('room_02.tmx', Vector2.all(16));

    randMap(map, this, entityList);
    setupCamera(map);
    spawnDoor(map);
    room = AddRoom(room: map, entityList: entityList);
    print('this $entityList');

    // save 'map' 'entity' to linked map

    cam.world = room;

    await add(room!);
    print(children.whereType<AddRoom>());
  }

  void reset() {
    player.reset();

    cam.world!.children.whereType<Player>().forEach((element) {
      print('player clean');
      element.removeFromParent();
    });

    cam.world!.children.whereType<Enemy>().forEach((element) {
      element.removeFromParent();
    });
    cam.world!.children.whereType<Projectile>().forEach((element) {
      element.removeFromParent();
    });
    cam.world!.children.whereType<Obstacle>().forEach((element) {
      element.removeFromParent();
    });
    cam.world!.children.whereType<Door>().forEach((element) {
      element.removeFromParent();
    });
    cam.world!.children.whereType<Item>().forEach((element) {
      element.removeFromParent();
    });
    cam.world!.children.whereType<GamePlatform>().forEach((element) {
      element.removeFromParent();
    });
  }

  void spawnDoor(TiledComponent<FlameGame<World>> room) {
    double horizontal =
        (room.tileMap.map.width * room.tileMap.map.tileWidth).toDouble();
    double vertical =
        (room.tileMap.map.height * room.tileMap.map.tileHeight).toDouble();

    // for(var x = 0; x < 1; x++){
    //   for(var x = 0; x < 1; x++){
    //     //door
    //   }
    // }

    final door = Door(
      position: Vector2(horizontal / 2, 0 + 16),
      size: Vector2.all(24),
    );
    final doorBottom = Door(
      position: Vector2(horizontal / 2, vertical - 16),
      size: Vector2.all(24),
    );
    final ldoor = Door(
      position: Vector2(0 + 16, vertical / 2),
      size: Vector2.all(24),
    );
    final rdoor = Door(
      position: Vector2(horizontal - 16, vertical / 2),
      size: Vector2.all(24),
    );

    entityList.addAll([door, doorBottom, ldoor, rdoor]);
  }

  void setupCamera(TiledComponent room) {
    cam.follow(player, maxSpeed: 200);
    cam.setBounds(
      Rectangle.fromLTRB(
        fixedResolution.x / 2,
        fixedResolution.y / 2,
        room.width - fixedResolution.x / 2,
        room.height - fixedResolution.y / 2,
      ),
    );
  }
}
