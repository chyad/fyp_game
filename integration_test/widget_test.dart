import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fyp_game/main.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();


  final newgame = find.text('New Game');
  final resume = find.text('Resume');
  final settings = find.text('Settings');
  final leaderboard = find.text('Leaderboard');

  final back = find.byIcon(Icons.arrow_back);

  group('Home screen', () {
    Future<Null> testMainMenu(WidgetTester tester) async {
      expect(find.text('home screen'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsExactly(4));

      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
    }
    Future<Null> testSettings(WidgetTester tester) async {
      await tester.tap(settings);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsExactly(2));
      expect(find.byType(ElevatedButton), findsExactly(1));
      expect(back, findsExactly(1));

      await tester.tap(back);
      await tester.pumpAndSettle();
    }
    Future<Null> testLeaderboard(WidgetTester tester) async {
      await tester.tap(leaderboard);
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.byType(Visibility), findsExactly(1));
      expect(find.byType(ElevatedButton), findsExactly(2));
      expect(find.text('Retry'), findsOneWidget);
      expect(back, findsOneWidget);

      await tester.tap(back);
      await tester.pumpAndSettle();
    }

    testWidgets('MainMenu', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      await tester.pumpWidget(const MyApp());

      // splash screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      await testMainMenu(tester);
      await testSettings(tester);
      await testLeaderboard(tester);
    });
  });
}
