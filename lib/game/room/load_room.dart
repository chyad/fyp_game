import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class AddRoom extends World {
  late TiledComponent room;

  List<PositionComponent> entityList = [];

  AddRoom({
    required this.room,
    required this.entityList,
  });

  @override
  Future<FutureOr<void>> onLoad() async {
    add(room);

    for (var element in entityList) {
        add(element);
    }

  }
}
