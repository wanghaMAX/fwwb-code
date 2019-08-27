import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/** 代码从第 57 行开始 */

/* 自定义标题栏，废弃 */
class MAppBar extends StatefulWidget implements PreferredSizeWidget {
  MAppBar({@required this.child}) : assert(child != null);
  
  final Widget child;
  var color = Colors.deepOrange;
  
  @override
  Size get preferredSize {
    return new Size.fromHeight(56.0);
  }
  
  @override
  State createState() {
    return new MAppBarState();
  }
}
class MAppBarState extends State<MAppBar> {
  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      top: true,
      child: widget.child,
    );
  }
  /*
  Widget build(BuildContext context) {
    return widget.child;
  }
  */
}

/* 主题，废弃 */
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
  platform: TargetPlatform.iOS,
  tabBarTheme: TabBarTheme(

  )
);
final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);


/* “动态”页 */
class DynamicsPage extends StatefulWidget {
  DynamicsPage({Key key}) : super(key: key);

  @override
  DynamicsPageState createState() => new DynamicsPageState();
}

class DynamicsPageState extends State<DynamicsPage> {
  
  // 标签页
  List<Widget> tabpage = [
    CustomScrollView(
    slivers: <Widget>[
        
      ]
    ),
    Text('tab2'),
    Text('tab3')
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow[600],
          title: Container(
            padding: EdgeInsets.all(4),
            color: Color.fromARGB(127, 255, 255, 255),
            child: GestureDetector(
              child: Row(
                children: <Widget>[
                  Container(child: Icon(Icons.search, color: Colors.black87), margin: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                  Text('直接翻译/搜索动态/景点', style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              onTap: () {
                // TODO
                print("点击了搜索框");
              },
            ) 
          ),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              child: Center(
                child: TabBar(
                  isScrollable: true,
                  tabs: <Widget>[
                    new Tab(text: " 　头条　 "),
                    new Tab(text: " 　附近　 "),
                    new Tab(text: " 　订阅　 "),
                  ],
                  unselectedLabelColor: Colors.black38,
                  labelColor: Colors.yellow[900],
                  indicatorColor: Colors.yellow[900],
                ),
              ),
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              //width: double.infinity,
            )
          ),
          elevation: 1.5,
        ),
        body: Scaffold(
          appBar: AppBar(
            title: Text('666'),
          ),
          body: Text('home')
        
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.mail), title: Text('mail')),
            BottomNavigationBarItem(icon: Icon(Icons.mail), title: Text('mail')),
            BottomNavigationBarItem(icon: Icon(Icons.mail), title: Text('mail')),
            BottomNavigationBarItem(icon: Icon(Icons.mail), title: Text('mail', style: TextStyle(fontSize: 64))),
          ],
          // fixedColor: Colors.yellow,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            print(index);
          },
        ),
      ) 
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

}
