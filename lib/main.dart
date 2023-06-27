import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasedemos/FCMNotificationService.dart';
import 'package:firebasedemos/secondscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("testHandleback=>${message.notification?.title}");
}

final _pushMessagingNotification = FCMNotificationService();

PendingDynamicLinkData? initialLink;


Future<void> main() async {
  Get.testMode = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _pushNotificationMessage();
  _deepLinkingSetup();

  runApp(MyApp());
}

_pushNotificationMessage() async {
  await FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      debugPrint("getInitialMessage=>${message.notification?.title}");

      if (message.notification?.title != "") {
        Future.delayed(const Duration(milliseconds: 200), () async {
          Get.to(SecondScreen());
        });
      }
    }
  });
  await _pushMessagingNotification.initialize();
  //Handle Push Notification when app is in background and when app is terminated
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
}

_deepLinkingSetup() async {
  initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
}

_crashlyticsSetup() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(message: "Test", title: "Home"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;

  String? _linkMessage;
  bool _isCreatingLink = false;
  final String DynamicLink = 'https://testkishan.page.link/welcome';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
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
        onPressed: () {
           _createDynamicLink(false);
        //  Get.to(SecondScreen());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> initDynamicLinks() async {
    if (initialLink != null) {
      print("etst initialLink=>${initialLink?.link.path}");
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Get.to(SecondScreen());
      });
    }

    dynamicLinks.onLink.listen((dynamicLinkData) {
      print("etst=>${dynamicLinkData.link.path}");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SecondScreen(),
      //   ),
      // );
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Get.to(SecondScreen());
      });
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://testkishan.page.link',
      link: Uri.parse(DynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.firebasedemos',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.example.firebasedemos',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
      print("test=>${url}");
    } else {
      url = await dynamicLinks.buildLink(parameters);
      print("test11=>${url}");
    }
    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }
}
//when you get link just paste into any other place. when you click on that it will redirect on application.
//https://betterprogramming.pub/deep-linking-in-flutter-with-firebase-dynamic-links-8a4b1981e1eb
