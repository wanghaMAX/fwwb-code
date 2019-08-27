import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'WritingPage.dart';

class DynamicsTab extends StatefulWidget {
  DynamicsTab({Key key}) : super(key: key);

  @override
  DynamicsTabState createState() => new DynamicsTabState();
}

class DynamicsTabState extends State<DynamicsTab> {

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tDynamicsTab: build()');

    // 标签页
    List<Widget> tabpage = [
      CustomScrollView(
      slivers: <Widget>[
          
        ]
      ),
      ListView(
        children: <Widget>[
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
          Text('data'),
        ],
      ),
      Text('tab3')
    ];

    return Scaffold(   // 底栏脚手架
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 252, 201, 45),
            title: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(127, 255, 255, 255),
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              padding: EdgeInsets.all(4),
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
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                color: Colors.white,
                onPressed: () {
                  Navigator.push( context, new MaterialPageRoute(
                    builder: (context) { return new WritingPage(); },
                    settings: RouteSettings( isInitialRoute: true ),
                    maintainState: true
                  ));
                },
              )
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Container(
//              child: Center(
                  child: TabBar(
                    tabs: <Widget>[
                      new Tab(text: "推荐"),
                      new Tab(text: "附近"),
                      new Tab(text: "订阅"),
                    ],
                    unselectedLabelColor: Colors.black38,
                    labelColor: Colors.yellow[900],
                    indicatorColor: Colors.yellow[900],
                  ),
//              ),
                color: Colors.white,
                // padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              )
            ),
            elevation: 1.5,
          ),
          body: TabBarView(
            children: tabpage
          ),
        ),
      ),
    );
  }
}