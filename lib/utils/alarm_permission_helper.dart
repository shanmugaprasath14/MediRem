// lib/utils/alarm_permission_helper.dart
import 'dart:io'; // For Platform.isAndroid
import 'package:flutter/material.dart'; // For BuildContext, AlertDialog, etc.
import 'package:permission_handler/permission_handler.dart'; // For checking and requesting permissions
import 'package:device_info_plus/device_info_plus.dart'; // For getting Android SDK version

/// Checks and requests the SCHEDULE_EXACT_ALARM permission on Android.
/// On Android 12 (API 31) and above, this permission is required for exact alarms.
///
/// [context] is required to show the AlertDialog.
Future<void> checkExactAlarmPermission(BuildContext context) async {
  // Only proceed for Android platform
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final int sdkInt = androidInfo.version.sdkInt;

    debugPrint('Current Android SDK: $sdkInt');

    // Exact alarm permission is required from API 31 (Android 12) onwards
    if (sdkInt >= 31) {
      final status = await Permission.scheduleExactAlarm.status;
      debugPrint('ScheduleExactAlarm permission status: $status');

      if (status.isDenied) {
        // Permission is denied, so request it
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('ScheduleExactAlarm permission request result: $result');

        if (result.isDenied || result.isRestricted || result.isPermanentlyDenied) {
          // If the user denied it or it's permanently denied,
          // guide them to the app settings to grant it manually.
          _showPermissionDeniedDialog(context); // Pass the provided context
        }
      } else if (status.isPermanentlyDenied) {
        // Permission is permanently denied by the user.
        // Prompt them to open app settings.
        _showPermissionDeniedDialog(context); // Pass the provided context
      } else if (status.isGranted) {
        // Permission is already granted.
        debugPrint('ScheduleExactAlarm permission already granted.');
      }
    } else {
      // For Android versions below 12, this permission is not explicitly needed.
      debugPrint('Android SDK is below 31, SCHEDULE_EXACT_ALARM permission not explicitly required.');
    }
  }
}

/// Shows a dialog to inform the user that exact alarm permission is needed.
/// It takes a BuildContext to properly display the dialog.
void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflict with outer context
      return AlertDialog(
        title: const Text('Alarm Permission Required'),
        content: const Text(
          'For accurate medication reminders, please grant "Alarms & Reminders" permission in your app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Use dialogContext for navigation
            },
          ),
          ElevatedButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog first
              openAppSettings(); // Opens the app's system settings
            },
          ),
        ],
      );
    },
  );
}