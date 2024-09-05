import 'package:flutter/material.dart';
import 'package:fyp_game/game/gameplay.dart';
import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/screen/leaderboard.dart';
import 'package:fyp_game/game/screen/setting_menu.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    double textsize = 0.2;

    // print('main ${Provider.of<HiveMapda>(context, listen: false).map.isEmpty}');

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF5A6776), Color(0xFFff7b74)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent.withOpacity(0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Game title.
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: Text(
                  'main screen',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * textsize,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius:
                            MediaQuery.of(context).size.height * textsize * 0.2,
                        color: Colors.white,
                        offset: const Offset(0, 0),
                      )
                    ],
                  ),
                ),
              ),
              buttons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttons(BuildContext context) {
    double pad = 0.015;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Play button.
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                // Push and replace current screen (i.e MainMenu) with
                // SelectSpaceship(), so that player can select a spaceship.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GamePlay(newgame: true),
                  ),
                );
              },
              child: const Text('New Game'),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed:
                  Provider.of<HiveMapda>(context, listen: false).map.isEmpty
                      ? null
                      : () {
                          // Push and replace current screen (i.e MainMenu) with
                          // SelectSpaceship(), so that player can select a spaceship.
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => GamePlay(newgame: false),
                            ),
                          );
                        },
              child: const Text('Resume'),
            ),
          ),
        ),

        // Settings button.
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsMenu(),
                  ),
                );
              },
              child: const Text('Settings'),
            ),
          ),
        ),
        // Settings button.
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Leaderboard(),
                  ),
                );
              },
              child: const Text('Leaderboard'),
            ),
          ),
        ),
      ],
    );
  }
}
