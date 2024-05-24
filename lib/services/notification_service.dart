import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
    static final NotificationService _notificationService = NotificationService._internal();

    factory NotificationService() {
        return _notificationService;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    NotificationService._internal();

    Future<void> init() async {
        const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

        const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
        );

        const InitializationSettings initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
        );

        tz.initializeTimeZones();

        await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
        const String channelId = 'todo_channel';
        const String channelName = 'To-Do Notifications';
        const String channelDescription = 'Notification channel for to-do reminders';

        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            const NotificationDetails(
                android: AndroidNotificationDetails(
                    channelId,
                    channelName,
                    channelDescription,
                    importance: Importance.high,
                    priority: Priority.high,
                    showWhen: false,
                ),
                iOS: IOSNotificationDetails(),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
        );
    }
}
