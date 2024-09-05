import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/room/room_detail.dart';
import 'package:fyp_game/game/screen/main_menu.dart';
import 'package:fyp_game/game/screen/setting_menu.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final FypGame game;

  const PauseMenu({super.key, required this.game});

  // map display all
  final bool debug = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(180),
      body: tempSrc(context),

      //
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
                  "${e.key}:",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.05),
                ),
                Text(
                  "${e.value}",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.05),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget mapRoom(int x, int y, BuildContext context) {
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

    if (!(room.visited || room.visible) && !debug) {
      if (debug) {
        return Text(
          '$x:$y',
          textAlign: TextAlign.center,
        );
      }
      return const SizedBox.shrink();
    }

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
          color = Colors.red[800]!;
          break;
        default:
          // todo
          iconData = null;
      }

      // iconData = room.visited ? iconData : Icons.not_listed_location_outlined;
      // color = room.visited ? color : Colors.blueGrey[800]!;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
        border: Border.all(
            color: Colors.grey[800]!,
            width: MediaQuery.of(context).size.height * 0.003),
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
          'Character Stats : ',
          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.07),
        ),
        _getListWidgets(game.player.status, context),
        Text(
          'PowerUps : ${game.player.powerup}',
          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.03),
        ),
      ],
    );
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
              game.overlays.remove(id);
              game.resumeEngine();
            },
            child: const Text('Resume'),
          ),
        ),
        SizedBox(
          width: game.fixedResolution.x * 0.2,
          height: game.fixedResolution.y * 0.1,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsMenu(),
                ),
              );
            },
            child: const Text('Setting'),
          ),
        ),
        SizedBox(
          width: game.fixedResolution.x * 0.2,
          height: game.fixedResolution.y * 0.1,
          child: ElevatedButton(
            onPressed: () {
              game.overlays.remove(id);
              // game.saveHiveMap1(game.roomMapList);

              game.reset();
              game.resumeEngine();

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

  Widget tempSrc(BuildContext context) {
    int minRoomX = 0;
    int minRoomY = 0;
    int roomX = 0;
    int roomY = 0;

    for (var element in game.roomMapList) {
      // debug, highlight visible
      if (element.visible || debug) {
        minRoomX = element.xid < minRoomX ? element.xid : minRoomX;
        minRoomY = element.yid < minRoomY ? element.yid : minRoomY;

        roomX = element.xid > roomX ? element.xid : roomX;
        roomY = element.yid > roomY ? element.yid : roomY;
      }
    }
    if (roomX - minRoomX < 3) {
      minRoomX -= 1;
      roomX += 1;
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
                        mapRoom(x, y, context),
                    //
                    // SizedBox.shrink(),
                    // Icon(
                    //   Icons.visibility,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.monetization_on_outlined,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.settings,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.star,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.warning_amber_rounded,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.extension,
                    //   color: Colors.blueGrey[700],
                    // ),
                    // Icon(
                    //   Icons.not_listed_location_outlined,
                    //   color: Colors.blueGrey[700],
                    // ),
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
