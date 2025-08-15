import 'package:flutter/material.dart';
import 'package:peep/model/app_state.dart';
import 'package:provider/provider.dart';

extension AppProviderExtension on BuildContext {
  AppState get readAppState => read<AppState>();
  AppState get watchAppState => watch<AppState>();
}

extension StringExtension on String? {
  String get orEmpty {
    if (this == null || this!.trim().isEmpty) {
      return "-";
    }
    return this!;
  }
}
