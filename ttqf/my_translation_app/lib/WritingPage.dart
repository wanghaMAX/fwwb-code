import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WritingPage extends StatefulWidget {
  WritingPage({Key key}) : super(key: key);

  @override
  WritingPageState createState() => new WritingPageState();
}

class WritingPageState extends State<WritingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(54),
        child: AppBar(
          title: Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  child: Text('返回'),
                  onPressed: (){},
                ),
                Text('编辑'),
                RaisedButton(
                  child: Text('发布'),
                  onPressed: (){},
                ),
              ],
            ),
          ),
          elevation: 1,
          automaticallyImplyLeading: false,
        ),
      ),
    );
  }

}