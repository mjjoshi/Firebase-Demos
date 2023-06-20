import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasedemos/secondscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class PushNotificationService {
  String deviceToken = '';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future initialize() async {
    if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    await _fcm.getToken().then((token) {
      deviceToken = token!;
      print("test=>${deviceToken}");
    });
    // Enable Background Notification to retrieve any message which caused the application to open from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    // This handles routing to a secific page when there's a click event on the notification
    void handleMessage(RemoteMessage message) {
      Get.to(SecondScreen());
    }

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
    // This handles background notifications when the app is not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    //Enable foreground Notification for iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // To handle messages while your application is in foreground for android we listen to the onMessage stream.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showNotification(message);
    });
    //This is used to define the initialization settings for iOS and android
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // This handles routing to a secific page when there's a click event on the notification
    void onSelectNotification(NotificationResponse notificationResponse) async {
      var payloadData = jsonDecode(notificationResponse.payload!);
      print("payload12222=>${payloadData}");
      Get.to(SecondScreen());
    }

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future showNotification(RemoteMessage message) async {
    // We create an Android Notification Channel that overrides the default FCM channel to enable heads up notifications.
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'fcm_default_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );
    // This creates the channel on the device and if a channel with an id already exists, it will be updated
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    //This is used to display the foreground notification
    if (message.notification != null) {
      RemoteNotification? notification = message.notification;
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        playSound: true,
        channelDescription: channel.description,
        priority: Priority.high,
        ongoing: true,
        styleInformation: const BigTextStyleInformation(''),
      );

      var iOSChannelSpecifics = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }
}
