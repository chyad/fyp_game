class CDTimer {
  final Map<Enum, double> cds = {};

  // init all basic behavior
  void initBehavior() {
    for (var value in Behavior.values) {
      add(value, 0);
    }
  }

  // pass character CD and check
  bool isReady(Enum key, double requiredTime) {
    return cds[key]! > requiredTime;
  }

  void resetTimer(Enum key) {
    cds.update(
      key,
      (value) => 0,
      ifAbsent: () => 0,
    );
  }

  // for debuff, buff
  // increase existing timer
  // or add to list when missing
  void add(Enum key, double time) {
    cds.update(
      key,
      (value) => value + time,
      ifAbsent: () => time,
    );
  }

  void reduce(Enum key, double time) {
    if (cds.containsKey(key)) {
      cds.update(
        key,
        (value) => value - time,
      );

      print('reduce1 $cds');

      if (cds[key]! < 0) {
        cds.remove(key);
      }

      print('reduce2 $cds');
    }
    print('in reduce');
  }

  // use in update(dt), keep track for timer
  void updateTime(double time) {
    cds.forEach((key, value) {
      cds.update(
        key,
        (value) => time + value,
      );
    });
  }

  // for buff / debuff
  void updateTimeReduce(double time) {
    cds.forEach((key, value) {
      cds.update(
        key,
        (value) => -time + value,
      );
      if (cds[key]! < 0) {
        print('remove $key');
        cds.remove(key);
      }
    });
  }
}

enum Behavior {
  // active
  attack,

  jump,
  rolling,

  // passive
  invicible,
  updateLastPosition,

  falling,
}

extension SkillFunction on Behavior {}
