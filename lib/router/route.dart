import 'package:go_router/go_router.dart';
import 'package:peep/ui/main/main_page.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    return null;
  },
  routes: [GoRoute(path: '/', builder: (context, state) => const MainPage())],
);
