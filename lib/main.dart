import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasedemos/PushNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:firebasedemos/secondscreen.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';


@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  print("testHandleback=>${message.notification?.title}");
}

final _pushMessagingNotification = PushNotificationService();
Future<void> main() async {
  Get.testMode = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);



  await FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print("getInitialMessage=>${message.notification?.title}");

      if (message.notification?.title != "") {
        Future.delayed(const Duration(milliseconds: 200), () async {
          Get.to(const SecondScreen());
        });
      }
    }
  });
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await _pushMessagingNotification.initialize();

  //Handle Push Notification when app is in background and when app is terminated
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  //var test = ["item1"];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(message: "sdsad",title: "sfsdf"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title,required this.message});

  final String title;
  final String message;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SecondScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
