import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/screen/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:fyp_game/game/hive_gamedata/map_data.dart';
import 'package:fyp_game/game/hive_gamedata/player_data.dart';
import 'package:fyp_game/game/hive_gamedata/setting.dart';

import 'package:fyp_game/game/screen/main_menu.dart';

final mapHive = ValueNotifier<bool>(false);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();

  runApp(const MyApp());

}

Future<Settings> getSettings() async {
  final box = await Hive.openBox<Settings>(Settings.settingsBox);
  final settings = box.get(Settings.settingsKey);

  if (settings == null) {
    box.put(Settings.settingsKey,
        Settings(soundEffects: true, backgroundMusic: true));
  }

  return box.get(Settings.settingsKey)!;
}

Future<HiveMapda> getHiveMap() async {
  final box = await Hive.openBox<HiveMapda>(HiveMapda.hiveMapBox);

  final hiveMap = box.get(HiveMapda.hiveMapKey);

  if (hiveMap == null) {
    box.put(
        HiveMapda.hiveMapKey,
        HiveMapda(
          map: [],
          currentX: 0,
          currentY: 0,
          playerPos: [],
        ));
  }

  print('map box');

  mapHive.value = true;

  return box.get(HiveMapda.hiveMapKey)!;
}

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  final playerData = box.get(PlayerData.playerDataKey);

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

  Hive.ignoreTypeId(3);

  Hive.registerAdapter<HiveRoom2>(HiveRoom2Adapter());
  Hive.registerAdapter<HiveEntity>(HiveEntityAdapter());

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<HiveMapda>(HiveMapdaAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<PlayerData>(
            create: (BuildContext context) => getPlayerData(),
            initialData: PlayerData.fromMap(PlayerData.defaultData)),
        FutureProvider<HiveMapda>(
            create: (BuildContext context) => getHiveMap(),
            initialData: HiveMapda(
              map: [],
              currentX: 0,
              currentY: 0,
              playerPos: [0.0],
            )),
        FutureProvider<Settings>(
            create: (BuildContext context) => getSettings(),
            initialData: Settings(soundEffects: false, backgroundMusic: false)),
      ],
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<PlayerData>.value(
              value: Provider.of<PlayerData>(context),
            ),
            ChangeNotifierProvider<HiveMapda>.value(
              value: Provider.of<HiveMapda>(context),
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
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'BungeeInline',
          scaffoldBackgroundColor: Colors.white.withAlpha(10),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
