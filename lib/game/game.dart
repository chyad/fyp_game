import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/entity/door.dart';
import 'package:fyp_game/game/entity/enemy.dart';
import 'package:fyp_game/game/entity/item.dart';
import 'package:fyp_game/game/entity/obstacle.dart';
import 'package:fyp_game/game/entity/platform.dart';
import 'package:fyp_game/game/entity/player.dart';
import 'package:fyp_game/game/entity/projectile.dart';
import 'package:fyp_game/game/entity/static_entity/next_floor.dart';
import 'package:fyp_game/game/entity/static_entity/powerup.dart';
import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';
import 'package:fyp_game/game/hud/audio_component.dart';

import 'package:fyp_game/game/hud/hud.dart';
import 'package:fyp_game/game/overlay/game_over_menu.dart';
import 'package:fyp_game/game/room/generate_room.dart';
import 'package:fyp_game/game/room/load_room.dart';
import 'package:fyp_game/game/room/random_walk.dart';

import 'package:fyp_game/game/room/room.dart';
import 'package:fyp_game/game/room/room_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FypGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final fixedResolution = Vector2(640, 320);

  final int maxInt = 4294967296;
  bool gameReset = false;
  bool newGame = false;

  AddRoom? room;

  Player player = Player(
    position: Vector2(320, 160),
  );
  PowerUp powerup = PowerUp(position: Vector2(160, 160));

  late AudioComponent audio;
  late PlayerData playerData;
  late HiveMapda hiveMap;

  @override
  Color backgroundColor() => Color.fromARGB(255, 192, 247, 239);

  final updateData = ValueNotifier<int>(0);

  late Hud hud;
  late final CameraComponent cam;

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
    key: ComponentKey.named('movement'),
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

  List<PositionComponent> entityList2 = [];
  List<RoomDetail> roomMapList = [];

  int currentX = 0;
  int currentY = 0;
  int floor = 1; // todo

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    audio = AudioComponent();

    await FlameAudio.audioCache.loadAll([
      'sunrise-anna-li-sky-wav-8476.mp3',
      'explosion.wav',
    ]);
    print('bgm audio init');

    hud = Hud(priority: 1);
    cam = CameraComponent.withFixedResolution(
      width: fixedResolution.x,
      height: fixedResolution.y,
      hudComponents: [
        hud,
        joystickMovement,
        joystickAttack,
      ],
    );

    await add(cam);

    add(ScreenHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    // todo music, gameover check
    player.deathCheck();

    super.update(dt);
  }

  @override
  void onAttach() async {
    // map is rand in gameplay file.

    if (buildContext != null) {
      // Get the PlayerData from current build context without registering a listener.
      playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      hiveMap = Provider.of<HiveMapda>(buildContext!, listen: false);
      // Update the current spaceship type of player.
      // _player.setSpaceshipType(playerData.spaceshipType);
    }

    RoomDetail room;
    // currentX = hiveMap.currentX;
    // currentY = hiveMap.currentY;

    // move start point to middle of the map

    final temp = roomMapList
        .where((element) => element.xid == currentX && element.yid == currentY);

    room = temp.first;

    loadRoomDetail(temp.first);
    audio.playBgm('sunrise-anna-li-sky-wav-8476.mp3');

    super.onAttach();
  }

  @override
  void onDetach() {
    audio.stopBgm();
    super.onDetach();
  }

  void loadRoomDetail(RoomDetail roomData) async {
    room?.removeFromParent();
    gameReset = false;

    roomData.visited = true;
    roomData.visible = true;

    print(
        'load room ${roomData.xid}|${roomData.yid} ${roomData.entityList.whereType<Door>().length}');

    room = AddRoom(room: roomData.map, entityList: roomData.entityList);

    setupCamera(roomData.map);

    cam.world = room;

    cam.world?.add(audio);
    await add(room!);

    if (cam.world!.children.whereType<Enemy>().isEmpty) {
      saveHiveMap1(roomMapList);
    }
  }

  void reset() {
    gameReset = true;

    currentX = 0;
    currentY = 0;

    cam.world!.children.whereType<Player>().forEach((element) {
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
    cam.world!.children.whereType<NextFloor>().forEach((element) {
      element.removeFromParent();
    });

    // cam.removeFromParent();
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

  Future<void> ranMap({int seed = -1, bool newgame = false}) async {
    final randomSeed = (seed == -1) ? Random().nextInt(maxInt) : seed;
    final random = Random(randomSeed);

    int roomSeed = random.nextInt(maxInt);

    print('ranMap, $randomSeed, $roomSeed');

    roomMapList.clear();
    if (newgame) {
      newGame = newgame;
    }

    int roomMin = 10;
    int roomAdd = 10;

    int walkCount = 50;
    int roomCount = random.nextInt(roomAdd + 1) + roomMin;
    player = Player(position: Vector2(320, 160));

    int shopMax = 2;
    int defaultRoomCount = (roomCount - 2 - shopMax);
    double puzzleMax =
        random.nextDouble() * defaultRoomCount / 4 + defaultRoomCount / 4;

    print(
        'rand map  defroomC $defaultRoomCount ${defaultRoomCount / 4}, p${puzzleMax.round()} $puzzleMax');

    List<String> roomList =
        initRoomList(shopMax, puzzleMax.toInt(), roomCount - 2);

    int x = 0;
    int y = 0;

    // add 0 0 room
    await addRoom(roomMapList, 0, 0, seed: roomSeed, roomType: 'startPoint');

    // for (int i = 0; i < walkCount; i++) {
    while (roomMapList.length < roomCount) {
      bool xy = random.nextBool();
      bool dir = random.nextBool();
      roomSeed = random.nextInt(maxInt);

      if (roomList.isEmpty) {
        print('roomlist add boss');
        roomList.add('boss');
      }

      if (xy) {
        x += dir ? 1 : -1;

        // y = x.abs() > 5 ? 0 : y;
        // x = x.abs() > 5 ? 0 : x;
      } else {
        y += dir ? 1 : -1;

        // x = y.abs() > 5 ? 0 : x;
        // y = y.abs() > 5 ? 0 : y;
      }

      if (!roomExist(roomMapList, x, y)) {
        final int randomIndex = random.nextInt(roomList.length);
        String roomType = roomList[randomIndex];
        await addRoom(roomMapList, x, y, seed: roomSeed, roomType: roomType);
        roomList.removeAt(randomIndex);
      }
    }

    roomMapList.forEach((element) async {
      if (element.roomType == '') {
        await normRoomMap(element);
      }
    });

    // gen battle room, cliff style stack
    // filter room tpye '', modify map

    print('room count $roomCount : map ${roomMapList.length}');

    print(
        'game map ${roomMapList.length} first ${roomMapList.first.xid} | ${roomMapList.first.yid}');
  }

  List<String> initRoomList(int shop, int puzzle, int roomCount) {
    List<String> temp = [];
    for (var i = 0; i < shop; i++) {
      temp.add('shop');
    }
    for (var i = 0; i < puzzle; i++) {
      temp.add('puzzle');
    }
    for (var i = 0; i < (roomCount - puzzle - shop); i++) {
      temp.add('');
    }
    return temp;
  }

  Future<void> loadHiveMap(HiveMapda map) async {
    newGame = false;
    player = Player(position: Vector2(map.playerPos[0], map.playerPos[1]));

    currentX = map.currentX;
    currentY = map.currentY;

    roomMapList.clear();

    for (var e in map.map) {
      await loadHiveRoom(roomMapList, e);
    }
    roomMapList.forEach((element) async {
      if (element.roomType == '') {
        await normRoomMap(
          element,
          hive: true,
        );
        // add from hive e list
      }
    });

    print(
        'game map ${roomMapList.length} first ${roomMapList.first.xid} | ${roomMapList.first.yid}');
  }

  bool roomExist(List<RoomDetail> list, int x, int y) {
    return (list.where((element) => element.xid == x && element.yid == y))
        .isNotEmpty;
  }

  Future<void> addRoom(List<RoomDetail> list, int x, int y,
      {int seed = -1, String roomType = ''}) async {
    List<PositionComponent> tmepEntityList = [];

    String roomFile = roomType == 'boss' ? 'room_02' : 'room_02';
    // if boss, another map

    TiledComponent tmepMap =
        await TiledComponent.load('$roomFile.tmx', Vector2.all(16));

    //switch type todo
    switch (roomType) {
      case 'startPoint':
        bossMap(tmepMap, this, tmepEntityList, seed: seed);
        break;
      case 'puzzle':
        bossMap(tmepMap, this, tmepEntityList, seed: seed);
        spawnPowerUp(tmepMap, tmepEntityList, roomType);
        break;
      case 'shop':
        bossMap(tmepMap, this, tmepEntityList, seed: seed);
        spawnPowerUp(tmepMap, tmepEntityList, roomType);
        break;
      case 'boss':
        bossMap(tmepMap, this, tmepEntityList, seed: seed);
        addBossEnemy(tmepMap, tmepEntityList, roomType);
        spawnNextFloor(tmepMap, tmepEntityList);
        break;
      default:
    }

    // symmetircMap(tmepMap, this, tmepEntityList, seed: seed);

    tmepEntityList.add(player);
    spawnDoor(tmepMap, tmepEntityList);

    final rm = RoomDetail(
      seed: seed,
      xid: x,
      yid: y,
      roomType: roomType,
      map: tmepMap,
      entityList: tmepEntityList,
    );

    list.add(rm);
  }

  Future<void> normRoomMap(RoomDetail room,
      {int seed = -1, String roomType = '', bool hive = false}) async {
    List<String> style = [
      'cliff',
      'full',
    ];

    final random = Random(room.seed);

    final int randomIndex = random.nextInt(style.length);
    String roomStyle = style[randomIndex];

    switch (roomStyle) {
      case 'full':
        bossMap(
          room.map,
          this,
          room.entityList,
          seed: room.seed,
        );
        if (!hive) {
          addEnemyFull(room.map, room.entityList, roomType);
        }
        break;
      case 'cliff':
        cliffMap(
          room,
          this,
          hive: hive,
        );
        break;
      default:
    }
  }

  Future<void> loadHiveRoom(List<RoomDetail> list, HiveRoom2 room) async {
    List<PositionComponent> tmepEntityList = [];
    String roomFile = room.roomType == 'boss' ? 'room_02' : 'room_02';
    TiledComponent tmepMap =
        await TiledComponent.load('$roomFile.tmx', Vector2.all(16));

    switch (room.roomType) {
      case 'startPoint':
        bossMap(tmepMap, this, tmepEntityList, seed: room.seed);
        break;
      case 'puzzle':
        bossMap(tmepMap, this, tmepEntityList, seed: room.seed);
        // spawnPowerUp(tmepMap, tmepEntityList, room.roomType);
        break;
      case 'shop':
        bossMap(tmepMap, this, tmepEntityList, seed: room.seed);
        // spawnPowerUp(tmepMap, tmepEntityList, room.roomType);
        break;
      case 'boss':
        bossMap(tmepMap, this, tmepEntityList, seed: room.seed);
        spawnNextFloor(tmepMap, tmepEntityList);
        break;
      default:
    }

    if (room.entityList.isNotEmpty) {
      addHiveEntity(room.entityList, tmepEntityList);
    }

    tmepEntityList.add(player);
    spawnDoor(tmepMap, tmepEntityList);

    final rm = RoomDetail(
      seed: room.seed,
      xid: room.roomX,
      yid: room.roomY,
      roomType: room.roomType,
      map: tmepMap,
      entityList: tmepEntityList,
      roomClear: room.roomClear,
      visible: room.visible,
      visited: room.visited,
    );

    list.add(rm);
  }

  void saveHiveMap1(List<RoomDetail> map) {
    late HiveRoom2 temp;

    hiveMap.map = [];

    hiveMap.currentX = currentX;
    hiveMap.currentY = currentY;

    hiveMap.playerPos = [player.position.x, player.position.y];

    for (var e in map) {
      List<HiveEntity> hiveEntity = [];

      e.entityList.whereType<Obstacle>().forEach((element) {
        final item = HiveEntity(
            entityType: 'obstacle',
            name: element.unmovable ? 'unmovalbe' : 'movable',
            position: [element.position.x, element.position.y],
            size: [element.size.x, element.size.y],
            other: '');
        hiveEntity.add(item);
      });
      e.entityList.whereType<Enemy>().forEach((element) {
        final item = HiveEntity(
            entityType: 'enemy',
            name: element.enemyType,
            position: [element.position.x, element.position.y],
            size: [element.size.x, element.size.y],
            other: '');
        hiveEntity.add(item);
      });
      e.entityList.whereType<PowerUp>().forEach((element) {
        final item = HiveEntity(
            entityType: 'powerup',
            name: element.menutype,
            position: [element.position.x, element.position.y],
            size: [element.size.x, element.size.y],
            other: element.itemCount.toString());
        hiveEntity.add(item);
      });

      temp = HiveRoom2(
        seed: e.seed,
        roomX: e.xid,
        roomY: e.yid,
        roomType: e.roomType,
        entityList: hiveEntity,
        roomClear: e.roomClear,
        visible: e.visible,
        visited: e.visited,
      );

      hiveMap.map.add(temp);
    }

    print(
        ' hive save:  map:l${hiveMap.map.length}, ${hiveMap.currentX}:${hiveMap.currentY}, player position:${hiveMap.playerPos}');

    player.savePlayerHive();

    hiveMap.save();
    // hp
  }

  void deleteMapRecord() {
    hiveMap.map = [];
    hiveMap.currentX = 0;
    hiveMap.currentY = 0;

    hiveMap.save();
  }

  Future<void> newFloor() async {
    await ranMap();

    floor += 1;
    print('floor ${floor}');

    final temp =
        roomMapList.where((element) => element.xid == 0 && element.yid == 0);

    loadRoomDetail(temp.first);
  }
}
