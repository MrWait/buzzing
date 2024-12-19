import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static final String sName = "home";
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("HomePage"),
          ],
        ),
      ),
    );
  }
}
