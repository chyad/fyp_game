import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fyp_game/game/game.dart';

import 'package:fyp_game/game/overlay/powerup_menu.dart';

int scoreMax = 1;

class StroopPuzzle extends StatelessWidget {
  static const id = 'StroopPuzzle';
  final FypGame game;

  const StroopPuzzle({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    double pad = 0.015;
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(180),
      appBar: AppBar(
        title: const Text('Stroop Effect Game'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
            child: Text(
              'Welcome to Stroop Effect Game!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
            child: SizedBox(
              width: game.fixedResolution.x * 0.2,
              height: game.fixedResolution.y * 0.1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StroopEffectGame(
                              game: game,
                            )),
                  );
                },
                child: Text('Start Game'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
            child: SizedBox(
              width: game.fixedResolution.x * 0.2,
              height: game.fixedResolution.y * 0.1,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(id);
                  game.resumeEngine();
                },
                child: Text('Return'),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class StroopEffectGame extends StatefulWidget {
  final FypGame game;
  const StroopEffectGame({super.key, required this.game});

  @override
  _StroopEffectGameState createState() => _StroopEffectGameState();
}

class _StroopEffectGameState extends State<StroopEffectGame> {
  int score = 0;
  int targetIndex = 0;
  int chance = 3;
  List<Color> buttonColors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 54, 124, 56),
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    const Color.fromARGB(255, 255, 102, 183),
    Colors.grey,
  ];
  List<String> colorNames = [
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Orange',
    'Purple',
    'Brown',
    'Pink',
    'Grey',
  ];
  List<int> buttonPositions = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  Color targetColor = Colors.red;

  int timerSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    generateTargetIndex();
    generateButtonPositions();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerSeconds++;
    });
  }

  void generateTargetIndex() {
    setState(() {
      targetIndex = Random().nextInt(9);
      targetColor = buttonColors[targetIndex];
    });
  }

  void generateButtonPositions() {
    setState(() {
      buttonPositions.shuffle();
    });
  }

  void checkAnswer(int index) {
    if (index == targetIndex) {
      setState(() {
        score++;
        if (score >= scoreMax) {
          _showWinDialog();

          widget.game.powerup.puzzleIsClear();
          widget.game.overlays.add(PowerUpMenu.id);
          widget.game.overlays.remove('StroopPuzzle');

          widget.game.resumeEngine();

          timer?.cancel();
        } else {
          generateTargetIndex();
          generateButtonPositions();
        }
      });
    } else {
      if (score >= scoreMax) {
        _showWinDialog();
      } else {
        setState(() {
          chance--;
          if (chance <= 0) {
            _showLossDialog();
          }
        });
      }
      generateTargetIndex();
      generateButtonPositions();
    }
  }

  bool isCorrectButton(int index) {
    return index == targetIndex;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('Time taken: $timerSeconds seconds'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to the start page
              },
              child: const Text('Return'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroop Effect Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Text(
              'game finish after ${scoreMax - score} points\nScore: $score  Chance: $chance',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.05),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 3.0,
              children: buttonPositions.map((position) {
                Color backgroundColor = isCorrectButton(position)
                    ? targetColor
                    : generateRandomColor(position);
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.015,
                      horizontal: MediaQuery.of(context).size.height * 0.05),
                  child: OutlinedButton(
                    onPressed: () {
                      checkAnswer(position);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: backgroundColor.withAlpha(50),
                      side: BorderSide(
                          width: MediaQuery.of(context).size.height * 0.01,
                          color: backgroundColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.02),
                      ),
                    ),
                    child: Text(
                      colorNames[position],
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.08,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                );
                //
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLossDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unfortunately!'),
          content: const Text('You Loss the game!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to the start page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color generateRandomColor(int position) {
    List<Color> availableColors = buttonColors
        .where(
            (color) => color != targetColor && color != buttonColors[position])
        .toList();
    int randomIndex = Random().nextInt(availableColors.length);
    return availableColors[randomIndex];
  }
}
