import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/overlay/pause_menu.dart';

class Hud extends Component with HasGameRef<FypGame> {
  late final TextComponent scoreTextComponent;
  late final TextComponent healthTextComponent;

  late RectangleComponent hpOutline;
  late RectangleComponent hpCount;

  double topYoffset = 0.05;

  double hpPortion = 1;
  double hpUnit = 0.02;

  var black = Paint()..color = Colors.black.withAlpha(100);
  var red = Paint()..color = Colors.red.withAlpha(100);

  Hud({super.children, super.priority});

  @override
  FutureOr<void> onLoad() async {
    print('hud onload');
    double hpPortion = game.player.hp / 100;
    final regular = TextPaint(
      style: TextStyle(
        fontSize: game.fixedResolution.y * topYoffset,
        color: Colors.white.withAlpha(255),
      ),
    );

    healthTextComponent = TextComponent(
      textRenderer: regular,
      position: Vector2.all(10),
      text: 'hp : ${game.player.hp}',
    );

    hpOutline = RectangleComponent(
      anchor: Anchor.topLeft,
      position: Vector2.all(10),
      size: Vector2(game.fixedResolution.x * hpUnit * 10,
          game.fixedResolution.y * topYoffset),
      paint: black,
    );

    hpCount = RectangleComponent(
      anchor: Anchor.topLeft,
      position: Vector2.all(10 + game.fixedResolution.y * topYoffset * 0.1),
      size: Vector2(
          (hpOutline.size.x - game.fixedResolution.y * topYoffset * 0.2) *
              hpPortion,
          hpOutline.size.y * 0.8),
      paint: red,
    );

    await add(hpOutline);
    await add(hpCount);

    await add(healthTextComponent);

    scoreTextComponent = TextComponent(
      text: '${game.player.money} : coin',
      textRenderer: regular,
      anchor: Anchor.topRight,
      position: Vector2(game.fixedResolution.x - 10, 10),
    );
    await add(scoreTextComponent);

    // coins or item list
    // game.playerData.score.addListener(onScoreChange);
    game.updateData.addListener(onHealthChange);

    final pauseButton = SpriteButtonComponent(
      onPressed: () {
        // AudioManager.pauseBgm();
        game.pauseEngine();
        game.overlays.add(PauseMenu.id);
      },
      button: Sprite(
        // buttons settings?
        game.images.fromCache('Main Characters/Appearing (96x96).png'),
        srcSize: Vector2.all(96),
        srcPosition: Vector2(96 * 2, 0),
      ),
      buttonDown: Sprite(
        game.images.fromCache('Main Characters/Appearing (96x96).png'),
        srcSize: Vector2.all(96),
        srcPosition: Vector2(96 * 3, 0),
      ),
      size: Vector2.all(32),
      anchor: Anchor.topCenter,
      position: Vector2(game.fixedResolution.x / 2, 5),
    );

    await add(pauseButton);

    return super.onLoad();
  }

  @override
  void onRemove() {
    // TODO: implement onRemove
    super.onRemove();
  }

  void onHealthChange() {
    healthTextComponent.text = 'hp : ${game.player.hp.floor()}';
    hpPortion = game.player.hp / 100;
    hpCount.size.x =
        (hpOutline.size.x - game.fixedResolution.y * topYoffset * 0.2) *
            hpPortion;

    scoreTextComponent.text = '${game.player.money} : coin';
  }
}
