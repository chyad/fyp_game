import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';

class StroopEffectGame extends StatefulWidget {
  static const id = 'Stroop';
  final FypGame game;

  const StroopEffectGame({super.key, required this.game});

  @override
  _StroopEffectGameState createState() => _StroopEffectGameState();
}

class _StroopEffectGameState extends State<StroopEffectGame> {
  int score = 0;
  int targetIndex = 0;
  List<Color> buttonColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
  List<String> colorNames = [
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Orange',
    'Purple',
    'Teal',
    'Pink',
    'Indigo',
  ];
  List<int> buttonPositions = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  Color targetColor = Colors.red;

  @override
  void initState() {
    super.initState();
    generateTargetIndex();
    generateButtonPositions();
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
        if (score >= 5) {
          _showWinDialog();
        } else {
          generateTargetIndex();
          generateButtonPositions();
        }
      });
    } else {
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
          content: const Text('You won the game!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Score: $score',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: buttonPositions.map((position) {
                Color backgroundColor = isCorrectButton(position)
                    ? targetColor
                    : generateRandomColor(position);
                return ElevatedButton(
                  onPressed: () {
                    checkAnswer(position);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: backgroundColor,
                    maximumSize: const Size(5, 5),
                    minimumSize: const Size(5, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    colorNames[position],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
