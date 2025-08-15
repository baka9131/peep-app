import 'package:flutter/material.dart';
import 'package:peep/common/localize/app_localizations.dart';
import 'package:peep/config/deeplink_config.dart';
import 'package:peep/config/sqflite_config.dart';
import 'package:peep/config/theme_config.dart';
import 'package:peep/model/app_state.dart';
import 'package:peep/router/route.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqfliteConfig().initialize();
  await AppState().initialize();

  runApp(
    ChangeNotifierProvider.value(value: AppState(), child: const Application()),
  );
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    DeepLinkConfig().initialize(context);
  }

  @override
  void dispose() {
    DeepLinkConfig().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PEEP',
      routerConfig: router,
      theme: ThemeConfig.theme,
      supportedLocales: [const Locale('ko')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
