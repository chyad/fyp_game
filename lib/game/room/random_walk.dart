import 'dart:math';

enum Direction { up, down, left, right }

void randomWalk() {
  List<Direction> direction = Direction.values;

  int n = 20;
  int x = 0;
  int y = 0;

  for (int i = 0; i < n; i++) {
    bool xy = Random().nextBool();
    bool dir = Random().nextBool();

    if (xy) {
      x += dir ? 1 : -1;
      print('random walk x, $x $y');
    } else {
      y += dir ? 1 : -1;
      print('random walk y, $x $y');
    }
  }
  print('random walk done, $x $y');
}
