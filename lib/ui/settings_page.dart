import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/services/notification_service.dart';
import 'package:peep/services/settings_service.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = false;
  TimeOfDay _checkInTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _checkOutTime = TimeOfDay(hour: 18, minute: 0);
  final TextEditingController confirmController = TextEditingController();

  PackageInfo? _packageInfo;
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadSettings();
  }

  @override
  void dispose() {
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final notificationEnabled = await _settingsService
          .getNotificationEnabled();
      final checkInTime = await _settingsService.getCheckInTime();
      final checkOutTime = await _settingsService.getCheckOutTime();

      if (mounted) {
        setState(() {
          _notificationEnabled = notificationEnabled;
          _checkInTime = checkInTime;
          _checkOutTime = checkOutTime;
        });
      }
    } catch (e) {
      debugPrint('설정 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSectionTitle('알림 설정'),
        const SizedBox(height: 16),
        _buildNotificationTile(),
        if (_notificationEnabled) ...[
          const SizedBox(height: 12),
          _buildTimeTile(
            title: '체크인 알림 시간',
            time: _checkInTime,
            onTap: () => _selectTime(true),
          ),
          const SizedBox(height: 12),
          _buildTimeTile(
            title: '체크아웃 알림 시간',
            time: _checkOutTime,
            onTap: () => _selectTime(false),
          ),
        ],
        const SizedBox(height: 32),
        _buildSectionTitle('데이터 관리'),
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.backup_outlined,
          title: '데이터 백업',
          subtitle: '현재 데이터를 백업합니다',
          onTap: _handleBackup,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.restore_outlined,
          title: '데이터 복원',
          subtitle: '백업된 데이터를 복원합니다',
          onTap: _handleRestore,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.delete_outline,
          title: '데이터 초기화',
          subtitle: '모든 데이터를 삭제합니다',
          onTap: _handleClearData,
          isDestructive: true,
        ),
        const SizedBox(height: 32),
        _buildSectionTitle('앱 정보'),
        const SizedBox(height: 16),
        if (_packageInfo != null) ...[
          _buildInfoTile('앱 이름', _packageInfo!.appName),
          const SizedBox(height: 12),
          _buildInfoTile(
            '버전',
            '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
          ),
          const SizedBox(height: 12),
        ] else ...[
          _buildLoadingTile('앱 정보 로딩 중...'),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomText(
      title,
      style: TextStyle(
        fontSize: kFontSizeLarge,
        fontWeight: kFontWeightSemiBold,
        color: kColorBlack,
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                '알림 사용',
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  fontWeight: kFontWeightMedium,
                ),
              ),
              const SizedBox(height: 4),
              CustomText(
                '체크인/아웃 시간에 알림을 받습니다',
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          CupertinoSwitch(
            value: _notificationEnabled,
            onChanged: (value) async {
              if (value) {
                final hasPermission = await _requestNotificationPermission();
                if (hasPermission) {
                  setState(() {
                    _notificationEnabled = true;
                  });
                  await _settingsService.setNotificationEnabled(true);
                  await _scheduleNotifications();
                }
              } else {
                await _notificationService.cancelAllReminders();
                setState(() {
                  _notificationEnabled = false;
                });
                await _settingsService.setNotificationEnabled(false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('알림이 비활성화되었습니다'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              title,
              style: TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: kFontWeightMedium,
              ),
            ),
            Row(
              children: [
                CustomText(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    color: kColorBlue,
                    fontWeight: kFontWeightMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : kColorBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: kFontWeightMedium,
                      color: isDestructive ? Colors.red : kColorBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label,
            style: TextStyle(fontSize: 16, fontWeight: kFontWeightMedium),
          ),
          CustomText(
            value,
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTile(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(kColorBlue),
            ),
          ),
          const SizedBox(width: 12),
          CustomText(
            text,
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });

      // 설정 저장
      try {
        if (isCheckIn) {
          await _settingsService.setCheckInTime(picked);
        } else {
          await _settingsService.setCheckOutTime(picked);
        }

        // 알림이 활성화되어 있다면 스케줄 업데이트
        if (_notificationEnabled) {
          await _scheduleNotifications();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${isCheckIn ? "체크인" : "체크아웃"} 알림 시간이 업데이트되었습니다'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('시간 설정 저장 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      await _notificationService.initialize();
      final hasPermission = await _notificationService.requestPermissions();

      if (hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 허용되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 초기화 실패: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<void> _scheduleNotifications() async {
    try {
      await _notificationService.cancelAllReminders();
      await _notificationService.scheduleCheckInReminder(_checkInTime);
      await _notificationService.scheduleCheckOutReminder(_checkOutTime);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 스케줄 설정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBackup() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('백업 기능은 추후 업데이트 예정입니다')));
  }

  void _handleRestore() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('복원 기능은 추후 업데이트 예정입니다')));
  }

  void _handleClearData() {
    // 먼저 현재 데이터 통계를 가져와서 보여주기
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text('데이터 초기화'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 모든 데이터를 삭제하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ 주의사항:',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 모든 체크인/체크아웃 기록이 삭제됩니다\n'
                    '• 삭제된 데이터는 복구할 수 없습니다\n'
                    '• 앱이 초기 상태로 돌아갑니다',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '계속하시려면 "초기화"를 입력하세요:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showConfirmationDialog();
            },
            child: Text('다음', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('최종 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '데이터를 초기화하려면 아래에 "초기화"라고 입력하세요.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: '초기화',
                hintStyle: TextStyle(color: kColorGrey5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (confirmController.text == '초기화') {
                Navigator.pop(dialogContext);
                await _performDataClear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('입력이 일치하지 않습니다. "초기화"라고 정확히 입력해주세요.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDataClear() async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('데이터 초기화 중...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 실제 데이터 초기화 수행
      final state = context.readAppState;
      final success = await state.clearAllData();

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context);
      }

      if (success) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('모든 데이터가 초기화되었습니다'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // 홈 화면으로 이동
        if (mounted) {
          state.setCurrentIndex(0);
        }
      } else {
        // 실패 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(state.errorMessage ?? '데이터 초기화에 실패했습니다')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context);
      }

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('오류가 발생했습니다: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
