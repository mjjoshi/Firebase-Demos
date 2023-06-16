import 'package:firebasedemos/secondscreen.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class RouteGenerator {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    final String routeName = settings.name!;

    switch (routeName) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Test',));

      case '/second':
        // final String itemId = args['itemId'];
        return MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        );
    }
  }
}