import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'publicVariable.dart';
import 'DynamicsTab.dart';
import 'UserInfoTab.dart';
import 'MapTab.dart';

class MainPage extends StatefulWidget {
  final PublicVar publicVar;
  MainPage({@required this.publicVar, Key key}) : super(key: key);

  @override
  MainPageState createState() => new MainPageState(publicVar);
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {

  PublicVar publicVar;
  MainPageState(this.publicVar) {
    navigationPage = [
      DynamicsTab(publicVar: publicVar),
      MapTab(),
      UserInfoTab(publicVar: publicVar)
    ];
  }

  // 各导航按钮的内容 ↑（因为要传非静态变量，所以分开写）
  List<Widget> navigationPage = [];
  int currentNavigationIndex = 0;
  bool showBottomSheet = false;

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tMainPage: build()');

    return Scaffold(
      body: Stack(
        children: <Widget>[
          navigationPage[currentNavigationIndex],   // 页面
          Stack(                                    // 底部导航栏
            children: <Widget>[
              Positioned(                           // 导航按钮
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: CupertinoTabBar(
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('发现')),
                      BottomNavigationBarItem(icon: Icon(Icons.public), title: Text('周边')),
                      BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的')),
                      BottomNavigationBarItem(icon: Icon(Icons.camera, size: 0), title: Text('翻译', style: TextStyle(fontSize: 0),)),
                    ],
                    iconSize: 28,
                    currentIndex: currentNavigationIndex,
                    activeColor: Colors.orange,
                    onTap: (int index) {
                      if (index < 3) {
                        setState(() {
                          currentNavigationIndex = index;
                        });
                      }
                    },
                  ),
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(blurRadius: 8, color: Color.fromARGB(32, 0, 0, 0)),
                      BoxShadow(color: Colors.white)
                    ]
                  ),
                  height: 52,
                ),
              ),
              Positioned(                           // 浮动工具菜单
                left: 0,
                top: 0,
                right: showBottomSheet ? 0 : double.infinity,
                bottom: 0,
                child: GestureDetector(
                  child: Container(
                    color: Color.fromARGB(225, 255, 255, 255),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            ToolBoxBtn('货币转换', AssetImage('src/icons/currency_button.png'), (){ print('tapped');}),
                            ToolBoxBtn('文字翻译', AssetImage('src/icons/text_translate_button.png'), (){ print('tapped');}),
                            ToolBoxBtn('语音翻译', AssetImage('src/icons/voice_translate_button.png'), (){ print('tapped');}),
                            ToolBoxBtn('拍照翻译', AssetImage('src/icons/OCR_button.png'), (){ print('tapped');}),
                            SizedBox(height: 96)
                          ],
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      showBottomSheet = false;
                    });
                  },
                ),
              ),
              Positioned(                           // 大按钮
                right: -48,
                bottom: -48,
                child: Container(
                  width: 160,
                  height: 160,
                  child: RaisedButton(
                    child: Image.asset(showBottomSheet ? "src/icons/navigation_tools_pressed.png" : "src/icons/navigation_tools.png", width: 128),
                    onPressed: () {
                      setState(() {
                        showBottomSheet = !showBottomSheet;
                      });
                    },
                    color: Colors.transparent,
                    elevation: 0,
                    highlightElevation: 0,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    splashColor: Colors.transparent,
                    shape: CircleBorder(),
                  ) ,
                ),
              ),

            ],
          ),
        ],
      ),

    );

  /*
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.yellow[600],
            title: Container(
              padding: EdgeInsets.all(2),
              color: Color.fromARGB(127, 255, 255, 255),
              child: Flex(
                children: <Widget>[
                  Container(child: Icon(Icons.search, color: Colors.black87), margin: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                  Text('标题栏', style: TextStyle(fontSize: 18, color: Colors.black87)),
                ],
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
              )
            ),
            bottom: new TabBar(
              isScrollable: true,
              tabs: <Widget>[
                new Tab(text: "Tabs 1"),
                new Tab(text: "Tabs 2"),
                new Tab(text: "Tabs 3"),
                new Tab(text: "Tabs 4"),
                new Tab(text: "Tabs 5"),
                new Tab(text: "Tabs 6"),
              ],
            ),
            pinned: true,
          )
        ]
      )
    );
    */
    
    /*CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          pinned: true,
          expandedHeight: 0.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Demo'),
          ),
          title: Text("66666666",),
          centerTitle: true,
          
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 4.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                color: Colors.teal[100 * (index % 9)],
                child: Text('grid item $index'),
              );
            },
            childCount: 20,
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 50.0,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                color: Colors.lightBlue[100 * (index % 9)],
                child: Text('list item $index'),
              );
            },
            childCount: 10
          ),
        ),
      ],
    );*/
  }

  @override
  bool get wantKeepAlive => true;

}

/// 自定义大按钮弹出工具箱功能
/// 接收参数：按钮文本、按钮图标、点击时的回调
class ToolBoxBtn extends StatelessWidget {
  final String text;
  final ImageProvider<dynamic> image;
  final Function() onTapCallback;
  ToolBoxBtn(this.text, this.image, this.onTapCallback);
  
  @override
  Widget build(BuildContext context) {
    // print(new DateTime.now().toString() + '\tToolBoxBtn: build()');
    return FlatButton(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              child: Icon(Icons.keyboard_arrow_right, color: Colors.blueGrey[700]),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3))
                ]
              )
            ),
            SizedBox(width: MediaQuery.of(context).size.width - 8 - 64 - 8 - 128),
            Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                shadows: [Shadow(color: Colors.white, blurRadius: 32)]
              )
            ),
            SizedBox(
              child: Image(image: image),
              width: 64,
              height: 64,
            ),
          ],
        ),
        height: 80,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(colors: [Color.fromARGB(0, 255, 255, 255), Color.fromARGB(127, 255, 152, 0)]),
        // )
      ),
      color: Colors.transparent,
      splashColor: Colors.lime,
      highlightColor: Color.fromARGB(127, 255, 217, 102),
      onPressed: (){ onTapCallback(); },
    );
  }

}