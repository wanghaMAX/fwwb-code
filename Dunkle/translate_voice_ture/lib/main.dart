import 'package:flutter/material.dart';
import 'voice_translate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our App',
      theme: ThemeData(primaryColor: Colors.blueAccent),
      home: Homepage(),
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.blue,
          child: Text('按键'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => new VoiceTranslatePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}