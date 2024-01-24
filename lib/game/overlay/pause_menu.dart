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
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'hp : ${game.player.hp}',
                      style: TextStyle(fontSize: 36),
                    ),
                    Text(
                      'size : ${game.player.size}',
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'hp : ${game.player.hp}',
                      style: TextStyle(fontSize: 36),
                    ),
                    Text(
                      'size : ${game.player.size}',
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
              ],
            ),
            //
            Row(
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
                    onPressed: () {},
                    child: const Text('Setting'),
                  ),
                ),
                SizedBox(
                  width: game.fixedResolution.x * 0.2,
                  height: game.fixedResolution.y * 0.1,
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
          ],
        ),
      ),
    );
  }
}
