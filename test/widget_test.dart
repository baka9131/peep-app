import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peep/config/sqflite_config.dart';
import 'package:peep/main.dart';
import 'package:peep/model/app_state.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App should start with home screen', (WidgetTester tester) async {
    await SqfliteConfig().initialize();
    await AppState().initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState(),
        child: const Application(),
      ),
    );

    expect(find.text('오늘의 기록'), findsOneWidget);
    expect(find.text('체크인'), findsOneWidget);
  });

  testWidgets('Bottom navigation should have correct items', (
    WidgetTester tester,
  ) async {
    await SqfliteConfig().initialize();
    await AppState().initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState(),
        child: const Application(),
      ),
    );

    expect(find.byIcon(Icons.home_filled), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('기록'), findsOneWidget);
  });

  testWidgets('Check button should be tappable when enabled', (
    WidgetTester tester,
  ) async {
    await SqfliteConfig().initialize();
    await AppState().initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState(),
        child: const Application(),
      ),
    );

    final checkButton = find.text('체크인');
    expect(checkButton, findsOneWidget);

    await tester.tap(checkButton);
    await tester.pumpAndSettle();

    // After check-in, button should change to 체크아웃
    expect(find.text('체크아웃'), findsOneWidget);
  });

  testWidgets('Navigation between tabs should work', (
    WidgetTester tester,
  ) async {
    await SqfliteConfig().initialize();
    await AppState().initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState(),
        child: const Application(),
      ),
    );

    // Initially on home tab
    expect(find.text('오늘의 기록'), findsOneWidget);

    // Tap on history tab
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();

    // Should show history page title
    expect(find.text('히스토리'), findsOneWidget);
  });
}
