// lib/main.dart
import 'package:flutter/material.dart';
import 'package:medirem/ready_started_page.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:medirem/notification_service.dart';
import 'package:medirem/alarm_page.dart';
import 'package:medirem/models/user_profile.dart'; // Ensure this path is correct
import 'package:medirem/theme/theme_provider.dart';
import 'package:medirem/home_page.dart'; // Import your HomePage

import 'dart:convert';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Background notification tapped: ${notificationResponse.payload}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestNotificationPermission();

  tzdata.initializeTimeZones();

  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());

  // --- TEMPORARY FIX FOR HIVE SCHEMA MISMATCH ---
  // This line will delete the 'userProfileBox' if it exists.
  // This is for development to clear corrupted data.
  // REMOVE THIS LINE AFTER YOUR APP LAUNCHES SUCCESSFULLY ONCE!
  try {
    await Hive.deleteBoxFromDisk('userProfileBox');
    debugPrint('Successfully deleted old userProfileBox data.');
  } catch (e) {
    debugPrint('Could not delete userProfileBox (might not exist): $e');
  }
  // --- END TEMPORARY FIX ---

  await Hive.openBox<UserProfile>('userProfileBox'); // Now opens a fresh/empty box
  await Hive.openBox('appSettings');

  await NotificationService.initialize(_handleNotificationTap);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
  await NotificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    if (notificationAppLaunchDetails!.notificationResponse?.payload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(notificationAppLaunchDetails.notificationResponse!);
      });
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.request();
  if (status.isGranted) {
    debugPrint('Notification permission granted.');
  } else if (status.isDenied) {
    debugPrint('Notification permission denied.');
  } else if (status.isPermanentlyDenied) {
    debugPrint('Notification permission permanently denied. Open settings.');
    openAppSettings();
  }
}

void _handleNotificationTap(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    try {
      final Map<String, dynamic> payload = json.decode(notificationResponse.payload!);
      final int id = payload['id'];
      final String medicineName = payload['medicineName'] ?? 'Unknown Medicine';
      final String? imagePath = payload['imagePath'];
      final String? customSoundPath = payload['customSoundPath'];
      final int? pillCount = payload['pillCount'];

      debugPrint('Attempting to navigate to AlarmPage with payload: $payload');
      debugPrint('Payload customSoundPath: $customSoundPath');

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmPage(
            medicineName: medicineName,
            imagePath: imagePath,
            notificationId: id,
            customSoundPath: customSoundPath,
            pillCount: pillCount,
          ),
        ),
      ).then((_) {
        debugPrint('Navigated to AlarmPage.');
      });
    } catch (e) {
      debugPrint('Error parsing notification payload in _handleNotificationTap: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediRem',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const ReadyStartedPage(),
      navigatorKey: navigatorKey,
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}