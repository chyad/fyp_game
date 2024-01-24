import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/overlay/pause_menu.dart';
import 'package:fyp_game/game/overlay/stroop.dart';

FypGame fypgame = FypGame();

class GamePlay extends StatelessWidget {
  const GamePlay({super.key});

  @override
  Widget build(BuildContext context) {

    // moved to game onAttach to init game
    // fypgame.loadRoom('room_02');

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: GameWidget(
          game: fypgame,
          overlayBuilderMap: {
            // MainMenu.id: (context, game) => MainMenu(game: fypgame),

            PauseMenu.id: (context, FypGame game) => PauseMenu(game: game),
            StroopEffectGame.id: (context, FypGame game) =>
                StroopEffectGame(game: game),

            // GameOver.id: (context, game) => GameOver(game: game),
            // Settings.id: (context, game) => Settings(game: game),
          },
        ),
      ),
    );
  }
}
