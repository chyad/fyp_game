import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';

import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/overlay/pause_menu.dart';

class Hud extends Component with HasGameRef<FypGame> {
  late final TextComponent scoreTextComponent;
  late final TextComponent healthTextComponent;

  Hud({super.children, super.priority});

  @override
  FutureOr<void> onLoad() async {
    healthTextComponent = TextComponent(
      text: 'hp',
      position: Vector2.all(10),
    );
    await add(healthTextComponent);

    scoreTextComponent = TextComponent(
      text: 'item',
      anchor: Anchor.topRight,
      position: Vector2(game.fixedResolution.x - 10, 10),
    );
    await add(scoreTextComponent);

    // game.playerData.score.addListener(onScoreChange);
    game.updateData.addListener(onHealthChange);

    final pauseButton = SpriteButtonComponent(
      onPressed: () {
        // AudioManager.pauseBgm();
        game.pauseEngine();
        game.overlays.add(PauseMenu.id);
      },
      button: Sprite(
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
    print('hp : ${game.player.hp}');
    healthTextComponent.text = 'hp : ${game.player.hp}';

    // Load game over overlay if health is zero.
    if (game.playerData.hp <= 0) {
      // AudioManager.stopBgm();
      game.pauseEngine();
      game.overlays.add(PauseMenu.id);
      // game.overlays.add(GameOver.id);
    }
  }
}
