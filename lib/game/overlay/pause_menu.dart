import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/screen/main_menu.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final FypGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('hp : ${game.player.hp}'),
            
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(id);
                  game.resumeEngine();
                },
                child: const Text('Resume'),
              ),
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  print(game.world.children);
                  print(game.children);

                  game.overlays.remove(id);

                  for (var element in game.cam.world!.children) {
                    print(element);
                  }

                  game.reset();
                  game.resumeEngine();

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
        ),
      ),
    );
  }
}
