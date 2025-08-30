import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peep/ui/main/main_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    return null;
  },
  routes: [GoRoute(path: '/', builder: (context, state) => const MainPage())],
);
