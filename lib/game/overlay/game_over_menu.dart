import 'package:flutter/material.dart';
import 'package:fyp_game/api/crud.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/room/room_detail.dart';
import 'package:fyp_game/game/screen/main_menu.dart';

class GameOverMenu extends StatelessWidget {
  static const id = 'GameOverMenu';
  final FypGame game;

  GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(200),
      body: tempSrc(context),

      //
    );
    ;
  }

  Widget buttons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: game.fixedResolution.x * 0.2,
          height: game.fixedResolution.y * 0.1,
          child: ElevatedButton(
            onPressed: () {
              print('gameover post result');
              submitResult();
            },
            child: const Text('post API'),
          ),
        ),
        SizedBox(
          width: game.fixedResolution.x * 0.2,
          height: game.fixedResolution.y * 0.1,
          child: ElevatedButton(
            onPressed: () {
              print('testing ${game.player.hp}');
              game.player.updateHP(100);
              game.overlays.remove(id);
              game.resumeEngine();
            },
            child: const Text('debug Resume'),
          ),
        ),
        SizedBox(
          width: game.fixedResolution.x * 0.2,
          height: game.fixedResolution.y * 0.1,
          child: ElevatedButton(
            onPressed: () {
              game.player.hp = 100;
              game.player.reset();
              game.overlays.remove(id);

              game.reset();
              game.resumeEngine();

              // game lose, remove hive data
              game.deleteMapRecord();

              // game.loadRoom('room_02');

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainMenu(),
                ),
              );
            },
            child: const Text('Exit'),
          ),
        )
      ],
    );
  }

  Widget mapRoom(int x, int y) {
    // room type
    IconData? iconData;
    Color color = Colors.blueGrey[800]!;
    RoomDetail room;

    if (!game.roomExist(game.roomMapList, x, y)) {
      // return if no room
      return const SizedBox.shrink();
    }

    // if room exist then ...
    room = game.roomMapList
        .where((element) => element.xid == x && element.yid == y)
        .first;

    // debug use

    if (game.currentX == x && game.currentY == y) {
      iconData = Icons.location_on;
      color = Colors.orange;
    } else {
      switch (room.roomType) {
        case 'startPoint':
          iconData = Icons.star;
          color = Colors.teal[600]!;
          break;
        case 'puzzle':
          iconData = Icons.extension;
          color = Colors.blue[800]!;
          break;
        case 'shop':
          iconData = Icons.monetization_on_outlined;
          color = Colors.amber;
          break;
        case 'boss':
          iconData = Icons.warning_amber_rounded;
          color = Colors.red;
          break;
        default:
          // todo
          iconData = null;
      }

      iconData = room.visited ? iconData : Icons.not_listed_location_outlined;
      color = room.visited ? color : Colors.white70!;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
      child: Icon(
        iconData,
        color: color,
      ),
      // or null
    );
  }

  Widget playerStats(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Character Status',
          style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.blueGrey.withAlpha(200),
              color: Colors.blueGrey.withAlpha(200),
              fontSize: MediaQuery.of(context).size.height * 0.07),
        ),
        _getListWidgets(game.player.status, context),
      ],
    );
  }

  Widget _getListWidgets(Map map, BuildContext context) {
    return Column(
      children: map.entries
          .map(
            (e) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "${e.key}:\t${e.value}",
                  style: TextStyle(
                      color: Colors.blueGrey.withAlpha(200),
                      fontSize: MediaQuery.of(context).size.height * 0.05),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget tempSrc(BuildContext context) {
    int minRoomX = 0;
    int minRoomY = 0;
    int roomX = 0;
    int roomY = 0;

    for (var element in game.roomMapList) {
      // if (element.visible) {
      minRoomX = element.xid < minRoomX ? element.xid : minRoomX;
      minRoomY = element.yid < minRoomY ? element.yid : minRoomY;

      roomX = element.xid > roomX ? element.xid : roomX;
      roomY = element.yid > roomY ? element.yid : roomY;
      // }
    }

    // minRoomX = game.roomMapList.map((e) => e.visible ? e.xid : 0).reduce(min);

    print('temp screen x-$minRoomX y-$minRoomY x+$roomX y+$roomY');

    return Column(children: [
      Flexible(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: roomX - minRoomX + 3,
                    childAspectRatio: 1.15,
                  ),
                  shrinkWrap: true,
                  children: [
                    for (int y = minRoomY - 1; y < roomY + 2; y++)
                      for (int x = minRoomX - 1; x < roomX + 2; x++)
                        mapRoom(x, y),
                    //
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          style: TextStyle(
                              color: Colors.blueGrey.withAlpha(200),
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.05),
                          'Game over'),
                      playerStats(context),
                    ]),
              )
            ]),
      ),
      // add container padding
      Container(
        padding: const EdgeInsets.all(20),
        child: buttons(context),
      ),
    ]);
  }
}
