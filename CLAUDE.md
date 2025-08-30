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

## Recent Updates

### Major Code Improvements and Security Fixes
**Date**: 2025-08-30

오늘 진행된 주요 개선사항들을 문서화합니다:

#### 1. 보안 취약점 수정 및 Repository 패턴 도입
**SQL Injection 취약점 완전 해결:**
- 기존 raw SQL 쿼리를 parameterized query로 전환
- Repository 패턴 도입으로 데이터 계층 추상화
- 새로운 파일: `lib/repository/peep_repository.dart`

**주요 변경사항:**
```dart
// 기존 (취약한 코드)
await database.rawInsert('INSERT INTO PEEP(inout, dateTime) VALUES($type, "$dateString")');

// 개선된 코드 (안전한 코드)
await txn.insert('PEEP', {
  'inout': type.value,
  'dateTime': now.toIso8601String(),
}, conflictAlgorithm: ConflictAlgorithm.replace);
```

#### 2. 에러 처리 및 상태 관리 강화
**AppState 클래스 개선 (lib/model/app_state.dart):**
- try-catch 블록으로 모든 데이터 작업 래핑
- 로딩 상태 및 에러 메시지 관리 추가
- Repository 패턴 통합으로 관심사 분리

**주요 추가 기능:**
```dart
String? errorMessage;      // 에러 메시지 상태
bool isLoading = false;    // 로딩 상태

Future<bool> addCheckIn() async {
  try {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    // ... 안전한 데이터 작업
  } catch (e) {
    errorMessage = '체크인 실패: $e';
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
```

#### 3. 테스트 인프라 구축
**새로운 테스트 파일들:**
- `test/repository/peep_repository_test.dart`: Repository 계층 테스트
- `test/model/app_state_test.dart`: 상태 관리 테스트
- Mock 데이터베이스와 함께 단위 테스트 환경 구축

#### 4. UI/UX 대폭 개선

**홈 페이지 리디자인 (lib/ui/home_page.dart):**
- 그라디언트 배경으로 모던한 디자인
- 상태 카드 UI로 직관적인 정보 표시
- 체크인/체크아웃 버튼 차별화:
  - 체크인: 파란색 그라디언트 (Color(0xFF4A90E2) → Color(0xFF357ABD))
  - 체크아웃: 주황색 그라디언트 (Color(0xFFFF9800) → Color(0xFFF57C00))
- 햅틱 피드백 및 시각적 피드백 강화
- 카드 섀도우 및 애니메이션 효과 추가

**히스토리 페이지 개선 (lib/ui/history_page.dart):**
- 통계 헤더 추가 (총 일수, 총 기록)
- 확장 가능한 카드 형태로 날짜별 기록 표시
- 근무 시간 자동 계산 및 표시
- 기록 개수에 따른 색상 코딩 (짝수: 초록색, 홀수: 주황색)

#### 5. 설정 페이지 완전 구현

**데이터 관리 기능:**
- **다단계 확인 데이터 초기화**: 
  ```
  1차: 경고 대화상자 + 주의사항 표시
  2차: "초기화" 텍스트 입력 확인
  3차: 실제 데이터 삭제 + 로딩 표시
  ```
- 안전한 데이터 삭제 로직 구현
- 사용자 피드백 및 에러 처리

**앱 정보 통합:**
- package_info_plus 패키지 활용
- 실제 앱 이름, 버전, 빌드 번호 표시
- 로딩 상태 관리

#### 6. 디자인 시스템 통합

**테마 관리 개선:**
- `lib/ui/core/themes/text_style.dart` 파일로 폰트 설정 중앙화
- 일관된 색상 팔레트 적용
- withValues(alpha:) 사용으로 Flutter 최신 버전 호환성 확보

**Deprecated API 수정:**
- WillPopScope → PopScope 업데이트
- withOpacity() → withValues(alpha:) 전환

#### 7. Notification System Implementation

완전한 알림 시스템을 구현했습니다:

#### 1. NotificationService 클래스 (lib/services/notification_service.dart)
- **싱글톤 패턴**: 앱 전체에서 하나의 인스턴스만 사용
- **플랫폼별 권한 처리**: Android 13+와 iOS 각각 최적화된 권한 요청
- **한국 시간대 지원**: 'Asia/Seoul' 타임존 설정으로 정확한 시간 계산
- **예약 알림**: 매일 반복되는 체크인/체크아웃 리마인더
- **즉시 알림**: 체크인/체크아웃 성공 시 즉시 전송되는 피드백 알림

**주요 메서드:**
```dart
- initialize(): 알림 서비스 초기화 및 타임존 설정
- requestPermissions(): 플랫폼별 알림 권한 요청
- areNotificationsEnabled(): 현재 권한 상태 확인
- scheduleCheckInReminder(TimeOfDay): 체크인 리마인더 설정
- scheduleCheckOutReminder(TimeOfDay): 체크아웃 리마인더 설정
- showCheckInSuccessNotification(): 체크인 성공 알림
- showCheckOutSuccessNotification(): 체크아웃 성공 알림
- cancelAllReminders(): 모든 예약 알림 취소
```

#### 2. 설정 페이지 연동 (lib/ui/settings_page.dart)
- **알림 토글**: CupertinoSwitch로 직관적인 ON/OFF 제어
- **시간 선택기**: 체크인/체크아웃 시간을 개별적으로 설정 가능
- **권한 요청 플로우**: 
  - 토글 활성화 시 자동으로 권한 요청
  - 권한 거부 시 사용자에게 설정 안내 메시지 표시
  - 권한 허용 시 즉시 알림 스케줄 등록
- **실시간 피드백**: 설정 변경 시 즉시 SnackBar로 결과 표시
- **에러 처리**: 알림 초기화 실패, 스케줄 설정 실패 등 모든 에러 상황 대응

**사용자 경험:**
```
1. 알림 토글 ON → 권한 요청 → 허용 시 "알림 권한이 허용되었습니다" 메시지
2. 시간 변경 → 자동으로 알림 스케줄 업데이트 → "체크인 알림 시간이 업데이트되었습니다" 피드백
3. 알림 토글 OFF → 모든 예약 알림 취소 → "알림이 비활성화되었습니다" 확인
```

#### 3. 홈 페이지 성공 알림 (lib/ui/home_page.dart)
- **체크인/체크아웃 성공 시**: 자동으로 성공 알림 전송
- **안전한 에러 처리**: 알림 전송 실패해도 앱 동작에 영향 없음
- **기존 UX 유지**: 기존의 SnackBar 피드백과 햅틱 피드백 모두 유지

#### 4. 패키지 의존성 추가 (pubspec.yaml)
```yaml
dependencies:
  flutter_local_notifications: ^18.0.1  # 로컬 알림
  permission_handler: ^11.3.1           # 권한 관리
  timezone: ^0.9.4                      # 시간대 처리
```

#### 5. 알림 채널 설정
- **체크인 리마인더**: 'checkin_reminder' 채널, ID: 1001
- **체크아웃 리마인더**: 'checkout_reminder' 채널, ID: 1002
- **즉시 알림**: 'peep_channel' 채널
- **모든 알림**: HIGH 우선순위, 사운드/진동/뱃지 활성화

#### 6. 보안 및 성능 고려사항
- **권한 검사**: 매번 알림 전송 전 권한 상태 확인
- **초기화 최적화**: 이미 초기화된 경우 중복 초기화 방지
- **메모리 관리**: 싱글톤 패턴으로 불필요한 인스턴스 생성 방지
- **에러 복구**: 알림 실패 시에도 앱 핵심 기능 영향 없음

이 구현으로 사용자는 원하는 시간에 체크인/체크아웃 리마인더를 받을 수 있고, 성공적으로 기록했을 때도 즉시 피드백을 받을 수 있게 되었습니다.

## 개발 품질 개선 요약

### Before vs After 비교

**보안성:**
- Before: SQL Injection 취약점 존재
- After: 완전한 parameterized query 사용

**에러 처리:**
- Before: 에러 발생 시 앱 크래시 위험
- After: 포괄적인 try-catch와 사용자 친화적 에러 메시지

**코드 구조:**
- Before: UI와 데이터 로직이 혼재
- After: Repository 패턴으로 관심사 분리

**테스트:**
- Before: 테스트 코드 없음
- After: 단위 테스트 인프라 구축

**UI/UX:**
- Before: 기본적인 Material Design
- After: 사용자 정의 그라디언트, 햅틱 피드백, 애니메이션

**기능성:**
- Before: 기본적인 체크인/아웃 기능
- After: 알림 시스템, 통계, 안전한 데이터 관리

### 추가된 패키지들
```yaml
# 새로 추가된 의존성
dependencies:
  package_info_plus: ^8.1.2           # 앱 정보
  flutter_local_notifications: ^18.0.1 # 로컬 알림
  permission_handler: ^11.3.1         # 권한 관리
  timezone: ^0.9.4                    # 시간대 처리

dev_dependencies:
  mockito: ^5.4.4                     # 테스트 Mock
  build_runner: ^2.4.11               # 코드 생성
```

### 파일 구조 변화
```
새로 추가된 파일들:
├── lib/repository/peep_repository.dart    # 데이터 계층
├── lib/services/notification_service.dart # 알림 서비스
├── lib/ui/core/themes/text_style.dart     # 텍스트 스타일 중앙화
├── test/repository/peep_repository_test.dart
└── test/model/app_state_test.dart

대폭 개선된 파일들:
├── lib/model/app_state.dart          # 상태 관리 강화
├── lib/ui/home_page.dart             # UI/UX 완전 리디자인
├── lib/ui/history_page.dart          # 통계 및 카드 UI
└── lib/ui/settings_page.dart         # 완전한 설정 기능
```

이번 개선으로 PEEP 앱은 보안성, 안정성, 사용자 경험 모든 측면에서 프로덕션 수준의 품질을 갖추게 되었습니다.