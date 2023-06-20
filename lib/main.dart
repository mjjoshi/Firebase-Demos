import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasedemos/PushNotificationService.dart';
import 'package:firebasedemos/secondscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  print("testHandleback=>${message.notification?.title}");
}

final _pushMessagingNotification = PushNotificationService();
PendingDynamicLinkData? initialLink;
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
    initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

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
      home: const MyHomePage(message: "sdsad", title: "sfsdf"),
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
  int _counter = 0;

  String? _linkMessage;
  bool _isCreatingLink = false;
  final String DynamicLink = 'https://testkishan.page.link/welcome';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void _incrementCounter() {
   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SecondScreen()));
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
        Get.to(const SecondScreen());
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
        Get.to(const SecondScreen());
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