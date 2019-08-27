import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  @override
  TestPageState createState() => new TestPageState();
}

class TestPageState extends State<TestPage> {
  
  int _selectedIndex = 1;
  final _widgetOptions = [
    Text('Index 0: Home'),
    Text('Index 1: Business'),
    Text('Index 2: School'),
    Text('Index 2: School'),
    Text('Index 2: School'),
  ];
  GlobalKey _textfieldkey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: Text('titlebar'),
            color: Colors.lightBlue,
            width: double.infinity,
            height: double.infinity,
          ),
        titleSpacing: 0,
        bottom: PreferredSize(
          child: Container(
            color: Colors.orange,
            child: Text('bottom'),
            height: 40,
          ),
          preferredSize: Size.fromHeight(60),
        ),

      ),
      body: Container(
        child: TextField(
          key: _textfieldkey,
          // keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder()
          ),
          onChanged: (String text) {
            print('changed');
            RenderObject renderObject = _textfieldkey.currentContext.findRenderObject();
            print("semanticBounds:${renderObject.semanticBounds.size} paintBounds:${renderObject.paintBounds.size} size:${_textfieldkey.currentContext.size}");
          },
        ),
      ),
    );
  }

}


/*  AppBar 的高度控制

在 AppBar 有 PreferredSize 包围的情况下：
	AppBar PreferredSize：整个标题栏高度
	bottom 内容的 height：从标题栏下往上的 bottom 高度
	bottom PreferredSize：没有用
	当需要让 bottom 占满整个空间时，让 AppBar PreferredSize=bottom 内容的 height=需要的空间

在 AppBar 没有 PreferredSize 包围的情况下：
	Bottom PreferredSize：从 title 往下伸出的高度
	bottom 内容的 height：bottom 内容的高度，不满 Bottom PreferredSize 时，留出空隙；超过时，挤占 title 空间，title 高度最大值约 56 不可调，只可以被挤占

*/

