import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
  @override
  _secondScreen createState() => _secondScreen();
}

class _secondScreen extends State<SecondScreen> {



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: const Text(
          "Second Page",
          style: TextStyle(fontSize: 16,color: Colors.red),

      ),
    );
  }


}

