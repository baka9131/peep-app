import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/model/app_state.dart';
import 'package:peep/ui/history_page.dart';
import 'package:peep/ui/home_page.dart';
import 'package:peep/ui/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final AppState state = context.readAppState;
    Widget body;
    String title;
    switch (state.currentTabIndex) {
      case 0:
        body = HomeScreen();
        title = "오늘의 기록";
        break;
      case 1:
        body = HistoryPage();
        title = "히스토리";
        break;
      case 2:
        body = SettingsPage();
        title = "설정";
        break;
      default:
        body = HomeScreen();
        title = "오늘의 기록";
        break;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (state.currentTabIndex != 0) {
          state.setCurrentIndex(0);
          return;
        }

        // 홈 화면에서는 앱 종료.
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        resizeToAvoidBottomInset: false,
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: context.readAppState.currentTabIndex,
          elevation: 1.0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: "기록",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "설정",
            ),
          ],
          onTap: (index) {
            context.readAppState.setCurrentIndex(index);
            setState(() {});
          },
        ),
      ),
    );
  }
}
