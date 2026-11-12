
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
  'nsbm_campus_notifications',
  'NSBM Campus Notifications',
  description: 'Important notifications from NSBM Smart Campus.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background notification received: ${message.messageId}');
}

Future<void> initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Request notification permission.
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint(
    'Notification permission: ${settings.authorizationStatus}',
  );

  // Initialize local notifications.
  const androidSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  // Create Android notification channel.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

    // Listen for Firebase Installation ID.
  messaging.onRegistered.listen(
    (String installationId) {
      debugPrint('Firebase Installation registered successfully.');
    },
    onError: (error) {
      debugPrint('Firebase registration error: $error');
    },
  );

  // Register this app instance with Firebase.
  await messaging.register();

  // Handle notifications while app is open.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Foreground notification received.');

    final notification = message.notification;

    if (notification == null) return;

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: notification.title ?? 'NSBM Smart Campus',
      body: notification.body ?? 'You have a new notification.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nsbm_campus_notifications',
          'NSBM Campus Notifications',
          channelDescription:
              'Important notifications from NSBM Smart Campus.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  });

  // Handle notification taps when app is in background.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Notification opened: ${message.messageId}');
  });

  // Handle notification taps when app was terminated.
  final initialMessage = await messaging.getInitialMessage();

  if (initialMessage != null) {
    debugPrint('App opened from a notification.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await initializeNotifications();
  }

  runApp(const NSBMSmartCampusApp());
}

class NSBMSmartCampusApp extends StatelessWidget {
  const NSBMSmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSBM Smart Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
