import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';

import 'package:fyp_game/game/overlay/powerup_menu.dart';

class DrawPuzzle extends StatelessWidget {
  static const id = 'DrawingPuzzle';
  final FypGame game;

  const DrawPuzzle({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    double pad = 0.015;

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(180),
      appBar: AppBar(
        title: Text('Drawing in Both Hand'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * pad),
              child: Text(
                'Welcome to Drawing in Both Hand!',
                style: TextStyle(fontSize: 24),
              ),
            ),
            // SizedBox(height: 20),
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
                          builder: (context) => ShapeDrawingPage(
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
        ),
      ),
    );
  }
}

class ShapeDrawingPage extends StatefulWidget {
  final FypGame game;
  const ShapeDrawingPage({super.key, required this.game});

  @override
  _ShapeDrawingPageState createState() => _ShapeDrawingPageState();
}

class _ShapeDrawingPageState extends State<ShapeDrawingPage> {
  List<Offset> leftHandPoints = [];
  List<Offset> rightHandPoints = [];
  bool isDrawing = false;
  bool isShapeDetected = false;
  bool righthand = false;
  bool lefthand = false;
  bool wingame = false;
  String detectedShape = '';
  String leftHandShape = '';
  String rightHandShape = '';
  int timerSeconds = 0;
  Timer? timer;
  Timer? clearOffsetTimer; // 新增計時器變量

  @override
  void initState() {
    super.initState();
    generateMissionShapes();
    startTimer();
    startClearOffsetTimer(); // 啟動計時器
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timerSeconds++;
      });
    });
  }

  void startClearOffsetTimer() {
    clearOffsetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isDrawing) {
        setState(() {
          leftHandPoints.clear();
          rightHandPoints.clear();
          righthand = false;
          lefthand = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing in Both Hand'),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      isDrawing = true;
                      isShapeDetected = false;
                      detectedShape = '';
                      leftHandPoints.clear();
                      leftHandPoints.add(details.localPosition);
                    });
                  },
                  onPanUpdate: (details) {
                    if (isDrawing && !isShapeDetected) {
                      setState(() {
                        leftHandPoints.add(details.localPosition);
                      });
                    }
                  },
                  onPanEnd: (_) {
                    setState(() {
                      isDrawing = false;
                      detectShapes();
                    });
                  },
                  child: CustomPaint(
                    painter: ShapePainter(leftHandPoints),
                    child: Container(),
                  ),
                ),
              ),
              Container(
                width: 1.0, // Added line width
                color: Colors.black, // Added line color
              ),
              Expanded(
                child: GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      isDrawing = true;
                      isShapeDetected = false;
                      detectedShape = '';
                      rightHandPoints.clear();
                      rightHandPoints.add(details.localPosition);
                    });
                  },
                  onPanUpdate: (details) {
                    if (isDrawing && !isShapeDetected) {
                      setState(() {
                        rightHandPoints.add(details.localPosition);
                      });
                    }
                  },
                  onPanEnd: (_) {
                    setState(() {
                      isDrawing = false;
                      detectShapes();
                    });
                  },
                  child: CustomPaint(
                    painter: ShapePainter(rightHandPoints),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Timer: $timerSeconds seconds',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      leftHandShape,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Visibility(
                      visible: lefthand != null,
                      child: Text(
                        lefthand ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: lefthand ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20.0),
                Column(
                  children: [
                    Text(
                      rightHandShape,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Visibility(
                      visible: righthand != null,
                      child: Text(
                        righthand ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: righthand ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (wingame)
            Positioned.fill(
              child: WinScreen(timerSeconds),
            ),
        ],
      ),
    );
  }

  bool isLeftSide(Offset position) {
    double screenWidth = MediaQuery.of(context).size.width;
    return position.dx <= screenWidth / 2;
  }

  void generateMissionShapes() {
    final List<String> shapes = ['Circle', 'Triangle', 'Square'];
    final Random random = Random();
    leftHandShape = shapes[random.nextInt(shapes.length)];
    do {
      rightHandShape = shapes[random.nextInt(shapes.length)];
    } while (leftHandShape == rightHandShape);
  }

  void detectShapes() {
    if (leftHandPoints.length >= 3) {
      lefthand = detectShape(leftHandPoints, leftHandShape);
    }
    if (rightHandPoints.length >= 3) {
      righthand = detectShape(rightHandPoints, rightHandShape);
    }

    if (righthand && lefthand) {
      setState(() {
        wingame = true;
        widget.game.overlays.add(PowerUpMenu.id);
        widget.game.overlays.remove('DrawingPuzzle');
        widget.game.powerup.puzzleIsClear();
        widget.game.resumeEngine();

        timer?.cancel();
        clearOffsetTimer?.cancel(); // 取消計時器
      });
    }
  }

  bool detectShape(List<Offset> points, String missionShape) {
    bool missioncomplete = false;
    if (points.length >= 3) {
      switch (missionShape) {
        case 'Square':
          if (isSquare(points)) {
            setState(() {
              detectedShape = 'Square';
              isShapeDetected = true;
            });
          }
        case 'Circle':
          if (isCircle(points)) {
            setState(() {
              detectedShape = 'Circle';
              isShapeDetected = true;
            });
          }
          break;
        case 'Triangle':
          if (isTriangle(points)) {
            setState(() {
              detectedShape = 'Triangle';
              isShapeDetected = true;
            });
          }
          break;
      }
    }

    if (detectedShape == missionShape) {
      missioncomplete = true;
    }
    return missioncomplete;
  }
}

class WinScreen extends StatelessWidget {
  final int timerSeconds; // Timer value passed as a parameter

  WinScreen(this.timerSeconds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Congratulations!'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Congratulations, you won!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Time taken: $timerSeconds seconds', // Display the timer value
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Return'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> points;

  ShapePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

bool isCircle(List<Offset> points) {
  // Calculate the centroid of the points
  double sumX = 0.0;
  double sumY = 0.0;
  for (var point in points) {
    sumX += point.dx;
    sumY += point.dy;
  }
  double centerX = sumX / points.length;
  double centerY = sumY / points.length;

  // Calculate the average distance from the centroid
  double avgDistance = 0.0;
  for (var point in points) {
    double dx = point.dx - centerX;
    double dy = point.dy - centerY;
    avgDistance += sqrt(dx * dx + dy * dy);
  }
  avgDistance /= points.length;

  // Determine if the points form a circle based on a threshold
  double maxDeviation = avgDistance * 0.4; // Adjust this threshold as needed
  bool isCircle = true;
  for (var point in points) {
    double dx = point.dx - centerX;
    double dy = point.dy - centerY;
    double distance = sqrt(dx * dx + dy * dy);
    if ((distance - avgDistance).abs() > maxDeviation) {
      isCircle = false;
      break;
    }
  }

  return isCircle;
}

bool isSquare(List<Offset> points) {
  Offset topLeft = calculateTopLeftCorner(points);
  Offset topRight = calculateTopRightCorner(points);
  Offset bottomLeft = calculateBottomLeftCorner(points);
  Offset bottomRight = calculateBottomRightCorner(points);

  double xDiffTop = (topRight.dx - topLeft.dx).abs();
  double xDiffBottom = (bottomRight.dx - bottomLeft.dx).abs();
  double yDiffLeft = (bottomLeft.dy - topLeft.dy).abs();
  double yDiffRight = (bottomRight.dy - topRight.dy).abs();

  double xDiffSquared = (xDiffTop - xDiffBottom).abs();
  double yDiffSquared = (yDiffLeft - yDiffRight).abs();

  double xtolerance = 100;
  double ytolerance = 100;

  bool xEqual = (xDiffSquared.abs() < xtolerance);
  bool yEqual = (yDiffSquared.abs() < ytolerance);

  return (xEqual && yEqual);
}

bool isTriangle(List<Offset> points) {
  Offset topLeft = calculateTopLeftCorner(points);
  Offset topRight = calculateTopRightCorner(points);
  Offset bottomLeft = calculateBottomLeftCorner(points);
  Offset bottomRight = calculateBottomRightCorner(points);

  double xDiffTop = (topRight.dx - topLeft.dx).abs();
  double xDiffBottom = (bottomRight.dx - bottomLeft.dx).abs();

  double tolerance = xDiffBottom * 0.9;

  bool samepoint = xDiffTop < tolerance;

  if (samepoint) {
    bool triangle = (xDiffBottom / 2 - xDiffTop).abs() < tolerance;
    return triangle;
  }

  return false;
}

Offset calculateTopLeftCorner(List<Offset> points) {
  Offset topLeft = points[0];
  for (var point in points) {
    if (point.dx <= topLeft.dx && point.dy <= topLeft.dy) {
      topLeft = point;
    }
  }
  return topLeft;
}

Offset calculateTopRightCorner(List<Offset> points) {
  Offset topRight = points[0];
  for (var point in points) {
    if (point.dx >= topRight.dx && point.dy <= topRight.dy) {
      topRight = point;
    }
  }
  return topRight;
}

Offset calculateBottomLeftCorner(List<Offset> points) {
  Offset bottomLeft = points[0];
  for (var point in points) {
    if (point.dx <= bottomLeft.dx && point.dy >= bottomLeft.dy) {
      bottomLeft = point;
    }
  }
  return bottomLeft;
}

Offset calculateBottomRightCorner(List<Offset> points) {
  Offset bottomRight = points[0];
  for (var point in points) {
    if (point.dx >= bottomRight.dx && point.dy >= bottomRight.dy) {
      bottomRight = point;
    }
  }
  return bottomRight;
}
