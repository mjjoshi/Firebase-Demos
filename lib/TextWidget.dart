import 'package:flutter/material.dart';

import 'User.dart';


//this class is stateless widget so no set state method will use . data will update automatically.
class TextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final inheritedData = User.of(context)?.name;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Second screen'),
        ),
        body: Center(
          child: Text(
            "tetsstst",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
