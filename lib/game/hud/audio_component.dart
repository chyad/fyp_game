import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fyp_game/game/game.dart';
import 'package:fyp_game/game/hive_gamedata/setting.dart';
import 'package:provider/provider.dart';

class AudioComponent extends Component with HasGameRef<FypGame> {
  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache.loadAll([
      'sunrise-anna-li-sky-wav-8476.mp3',
      //
      'explosion.wav',
      'pickupCoin.wav',
      'hitHurt.wav',
      'laserShoot.wav',
      'powerUp.wav',
    ]);

    print('bgm audio init');

    return super.onLoad();
  }

  void playBgm(String filename) {
    print('play bgm');
    if (!FlameAudio.audioCache.loadedFiles.containsKey(filename)) {
      print('play bgm return');
      return;
    }

    if (game.buildContext != null) {
      if (Provider.of<Settings>(game.buildContext!, listen: false)
          .backgroundMusic) {
        FlameAudio.bgm.play(filename);
      }
    }
  }

  void playSfx(String filename) {
    if (game.buildContext != null) {
      if (Provider.of<Settings>(game.buildContext!, listen: false)
          .soundEffects) {
        FlameAudio.play(filename);
      }
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }
}
