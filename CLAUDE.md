# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "PEEP" that appears to be a personal tracking/recording app with the following key features:
- Daily record tracking with income/expense management
- History viewing of past records
- SQLite database for local data persistence
- Deep linking support
- Korean localization

## Development Commands

### Running the Application
```bash
flutter run                  # Run on connected device/emulator
flutter run -d chrome        # Run on web browser
flutter run -d ios           # Run on iOS simulator
flutter run -d android       # Run on Android emulator
```

### Building the Application
```bash
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app (requires macOS)
flutter build web            # Build for web
```

### Code Quality
```bash
flutter analyze              # Run static analysis
flutter format .             # Format all Dart files
```

### Dependencies
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade dependencies
```

## Architecture

### State Management
- Uses Provider pattern with a singleton `AppState` class (lib/model/app_state.dart)
- Main state container manages: current tab index, data lists, and grouped data maps
- State is initialized at app startup with SQLite data

### Navigation
- Uses GoRouter for declarative routing (lib/router/route.dart)
- Main navigation through bottom navigation bar with tabs: Home, History, Settings
- Deep linking configured through `DeepLinkConfig`

### Data Layer
- SQLite database via sqflite package for local persistence
- Data models use Freezed for immutable state and JSON serialization
- Database operations handled through `SqfliteConfig` singleton

### UI Structure
```
lib/
├── ui/                     # All UI pages and components
│   ├── main/              # Main page with bottom navigation
│   ├── core/themes/       # Theme configuration and text styles
│   ├── home_page.dart     # Today's records screen
│   ├── history_page.dart  # Historical records view
│   └── settings_page.dart # Settings screen
├── model/                  # Data models and state management
├── config/                 # App configuration (SQLite, themes, deep links)
├── common/                 # Shared utilities and widgets
├── router/                 # Navigation routing
└── extension/             # Dart extensions for convenience methods
```

### Platform Configuration
- Android: Minimum SDK configured in android/app/build.gradle.kts
- iOS: Configuration in ios/Runner.xcworkspace
- Uses custom Pretendard font family for Korean text

## Key Technical Details

- Flutter SDK: 3.8.1+
- Uses Material Design 3 theming
- Korean-only localization currently implemented
- Database table: "PEEP" for storing records
- State persistence through SQLite with automatic initialization on app start