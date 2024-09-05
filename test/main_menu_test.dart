import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_game/game/hive_gamedata/setting.dart';
import 'package:fyp_game/game/screen/main_menu.dart';
import 'package:fyp_game/game/screen/setting_menu.dart';
import 'package:fyp_game/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('splash screen to main menu', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('title'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsExactly(4));

    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
  });

  testWidgets('settings menu', (tester) async {
    await tester.pumpWidget(const MainMenu());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(Selector), findsExactly(2));

    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Background Music'), findsOneWidget);

    find.byIcon(Icons.arrow_back);
  });
}
