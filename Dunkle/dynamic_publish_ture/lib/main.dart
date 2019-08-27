import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'publishPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'translate_text_ture',
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('主页',style: TextStyle(color: Colors.black87,fontSize: 30.0),),
        backgroundColor: Colors.white70,
      ),
      child: Center(
        child: CupertinoButton(
          color: Colors.blueAccent,
          child: Text('按键'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => new PublishMainPage(),
              ),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
