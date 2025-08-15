import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:peep/model/app_state.dart';

class DeepLinkConfig {
  static final DeepLinkConfig _instance = DeepLinkConfig._();
  DeepLinkConfig._();
  factory DeepLinkConfig() => _instance;

  static StreamSubscription<Uri>? _linkSubscription;
  static StreamSubscription<Uri>? get linkSubscription => _linkSubscription;

  void initialize(BuildContext context) async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      if (uri.hasScheme && uri.scheme == "sweeto" && uri.host == "peep") {
        if (uri.path.isEmpty) return;

        switch (uri.path) {
          case '/checkin':
            AppState state = AppState();
            state.setAutoCheck(0);
            break;
          case '/checkout':
            AppState state = AppState();
            state.setAutoCheck(1);
            break;
        }
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
