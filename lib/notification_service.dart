import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);
  }

  static Future showDangerNotification() async {
    AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'danger_channel',
          'Danger Alerts',

          importance: Importance.max,
          priority: Priority.high,

          ongoing: true,
          autoCancel:false,

          sound: RawResourceAndroidNotificationSound('alarm'),

          // 🔥 AKTIFKAN GETAR
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),

          // 🔥 AKTIFKAN SUARA
          playSound: true,

          // 🔥 BIKIN POPUP (HEADS-UP)
          fullScreenIntent: true,
        );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(
      0,
      "DANGER ALERT",
      "Volcano status is DANGER!",
      details,
    );
  }
}
