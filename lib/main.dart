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
  // Get.to(SecondScreen());
//  _pushMessagingNotification.showNotification(message);
}

final _pushMessagingNotification = PushNotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  await FirebaseMessaging.instance.getInitialMessage();
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
    //FirebaseCrashlytics.instance.crash();
    return GetMaterialApp(
      title: 'Flutter demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondScreen()));

    // setState(() {
    //   _counter++;
    // });
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
