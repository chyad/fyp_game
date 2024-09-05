import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/overlay/game_over_menu.dart';
import 'package:fyp_game/game/overlay/pause_menu.dart';
import 'package:fyp_game/game/overlay/powerup_menu.dart';
import 'package:fyp_game/game/overlay/stroop.dart';
import 'package:fyp_game/game/overlay/draw_puzzle.dart';
import 'package:provider/provider.dart';

FypGame fypgame = FypGame();

class GamePlay extends StatefulWidget {
  late bool newgame;
  GamePlay({super.key, required this.newgame});

  @override
  _GameplayState createState() => _GameplayState();
}

class _GameplayState extends State<GamePlay> {
  var isLoaded = false;

  late HiveMapda hiveMap;

  @override
  void initState() {
    if (context != null) {
      hiveMap = Provider.of<HiveMapda>(context!, listen: false);
    }

    initMap(widget.newgame);

    super.initState();
  }

  initMap(bool newgame) async {
    print('in gameplay initMap');

    // the delay can be remove,
    // its for showing the replacement instead of freeze in home page
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (hiveMap.map.isEmpty) {
        newgame = true;
      }

      await newgame
          ? fypgame.ranMap(
              seed: -1,
              newgame: newgame,
            )
          : fypgame.loadHiveMap(hiveMap);

      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // moved to game onAttach to init game
    // fypgame.loadRoom('room_02');

    return Scaffold(
        body: Visibility(
      visible: isLoaded,
      replacement: const Center(
        child: CircularProgressIndicator(),
      ),
      child: PopScope(
        canPop: false,
        child: GameWidget(
          game: fypgame,
          overlayBuilderMap: {
            PauseMenu.id: (context, FypGame game) => PauseMenu(game: game),
            GameOverMenu.id: (context, FypGame game) =>
                GameOverMenu(game: game),
            // power upgrade
            PowerUpMenu.id: (context, FypGame game) => PowerUpMenu(game: game),

            // puzzle
            StroopPuzzle.id: (context, FypGame game) =>
                StroopPuzzle(game: game),
            DrawPuzzle.id: (context, FypGame game) => DrawPuzzle(game: game),
          },
        ),
      ),
    ));
  }
}
