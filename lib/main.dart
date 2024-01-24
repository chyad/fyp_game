import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';
import 'package:fyp_game/game/hive_gamedata/setting.dart';

import 'package:fyp_game/game/screen/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();

  runApp(MultiProvider(
    providers: [
      FutureProvider<PlayerData>(
          create: (BuildContext context) => getPlayerData(),
          initialData: PlayerData.fromMap(PlayerData.defaultData)),
      FutureProvider<Settings>(
          create: (BuildContext context) => getSettings(),
          initialData: Settings(soundEffects: false, backgroundMusic: false))
    ],
    builder: (context, child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerData>.value(
            value: Provider.of<PlayerData>(context),
          ),
          ChangeNotifierProvider<Settings>.value(
            value: Provider.of<Settings>(context),
          ),
        ],
        child: child,
      );
    },
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // Dark more because we are too cool for white theme.
      themeMode: ThemeMode.dark,
      // Use custom theme with 'BungeeInline' font.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'BungeeInline',
        scaffoldBackgroundColor: Colors.white.withAlpha(10),
      ),
      // MainMenu will be the first screen for now.
      // But this might change in future if we decide
      // to add a splash screen.
      home: const MainMenu(),
    ),
  ));

  // runApp(
  //   MaterialApp(
  //     title: 'game123',
  //     theme: ThemeData(primarySwatch: Colors.blue),
  //     home: Scaffold(
  //       backgroundColor: Colors.blue,
  //       body: GameWidget<FypGame>(
  //         game: (kDebugMode ? FypGame() : game),
  //         overlayBuilderMap: {
  //           // MainMenu.id: (context, game) => MainMenu(game: game),
  //           PauseMenu.id: (context, game) => PauseMenu(game: game),
  //         },
  //       ),
  //     ),
  //   ),
  // );
}

Future<Settings> getSettings() async {
  final box = await Hive.openBox<Settings>(Settings.settingsBox);
  final settings = box.get(Settings.settingsKey);

  // If settings is null, it means this is a fresh launch
  // of the game. In such case, we first store the default
  // settings in the settings box and then return the same.
  if (settings == null) {
    box.put(Settings.settingsKey,
        Settings(soundEffects: true, backgroundMusic: true));
  }

  return box.get(Settings.settingsKey)!;
}

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  final playerData = box.get(PlayerData.playerDataKey);

  // If player data is null, it means this is a fresh launch
  // of the game. In such case, we first store the default
  // player data in the player data box and then return the same.
  if (playerData == null) {
    box.put(
      PlayerData.playerDataKey,
      PlayerData.fromMap(PlayerData.defaultData),
    );
  }
  return box.get(PlayerData.playerDataKey)!;
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(GameMapAdapter());
  Hive.registerAdapter(SettingsAdapter());
}
