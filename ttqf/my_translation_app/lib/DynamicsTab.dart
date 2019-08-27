import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'publicVariable.dart';
import 'WritingPage.dart';
import 'DynamicsDetail.dart';

class DynamicsTab extends StatefulWidget {
  final PublicVar publicVar;
  DynamicsTab({@required this.publicVar, Key key}) : super(key: key);

  @override
  DynamicsTabState createState() => new DynamicsTabState(publicVar);
}

class DynamicsTabState extends State<DynamicsTab> {

  PublicVar publicVar;
  DynamicsTabState(this.publicVar);

  String locatedCity = "大不列颠岛";

  Future<Null> pullToRefresh() async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tDynamicsTab: build()');

    // 标签页
    List<Widget> tabpage = [
      RefreshIndicator(
        displacement: 30,
        onRefresh: pullToRefresh,
        child: ListView(
          children: <Widget>[
            DynamicsTile(
              userNickName: "滔滔清风",
              avatarUrl: 'http://backupserver.tencent.ttqf.tech/useravatar/20180908%20%E5%A4%B4%E5%83%8F.jpg',
              publishTime: "今天 20:10",
              position: MyLatLng(37.42796133580664, -122.085749655962),
              distance: "120.0 km",
              likes: 66.toString(),
              comments: 12.toString(),
              content: '这是说正事专用配图 1：![img](https://cn.bing.com/th?id=OHR.PWSRecovery_ZH-CN1234475074_1920x1080.jpg)这是说正事专用配图 2：![img](https://cn.bing.com/th?id=OHR.TashkurganGrasslands_ZH-CN1141881683_1920x1080.jpg)这是说正事专用配图 3：![img](https://cn.bing.com/th?id=OHR.springequinox_ZH-CN1099430476_1920x1080.jpg&rf=NorthMale_1920x1080.jpg&pid=hp)这是说正事专用配图 4：![img](https://cn.bing.com/th?id=OHR.springequinox_ZH-CN1099430476_1920x1080.jpg&rf=NorthMale_1920x1080.jpg&pid=hp)',
              tags: ['tag1', 'tag2', 'tag3'],
              likerHeadIconUrls: [
                'http://backupserver.tencent.ttqf.tech/useravatar/ava001.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava002.jpg',
              ],
              publicVar: publicVar,
            ),
            DynamicsTile(
              userNickName: "滔滔清风",
              avatarUrl: 'http://backupserver.tencent.ttqf.tech/useravatar/20180908%20%E5%A4%B4%E5%83%8F.jpg',
              publishTime: "今天 20:10",
              // position: MyLatLng(39.9, 116.4),
              position: MyLatLng(23.0622018780, 112.4575064808),
              distance: "120.0 km",
              likes: 66.toString(),
              comments: 12.toString(),
              content: '这是说正事专用配图 1：![img](https://cn.bing.com/th?id=OHR.PWSRecovery_ZH-CN1234475074_1920x1080.jpg)\n这是说正事专用配图 2：![img](https://cn.bing.com/th?id=OHR.TashkurganGrasslands_ZH-CN1141881683_1920x1080.jpg)\n这是说正事专用配图 3：![img](https://cn.bing.com/th?id=OHR.springequinox_ZH-CN1099430476_1920x1080.jpg&rf=NorthMale_1920x1080.jpg&pid=hp)\n这是说正事专用配图 4：![img](https://cn.bing.com/th?id=OHR.springequinox_ZH-CN1099430476_1920x1080.jpg&rf=NorthMale_1920x1080.jpg&pid=hp)',
              likerHeadIconUrls: [
                'http://backupserver.tencent.ttqf.tech/useravatar/ava001.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava002.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava003.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava004.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava005.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava006.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava007.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava008.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava009.jpg',
                'http://backupserver.tencent.ttqf.tech/useravatar/ava010.jpg',
              ],
              publicVar: publicVar,
            ),
            SizedBox(height: 128)
          ],
        ),
      ),
      // CustomScrollView(
      // slivers: <Widget>[
      //     
      //   ]
      // ),
      ListView(
        children: <Widget>[
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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(96),       // 标题栏总高度 ↓
            child: Container(   // 整个标题栏的阴影
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 8, color: Color.fromARGB(16, 0, 0, 0))]
              ),
              child: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                titleSpacing: 0,
                flexibleSpace: Image.asset('src/backgrounds/title_bg.png', fit: BoxFit.cover),
                backgroundColor: Colors.transparent,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(0),
                  child: Container(
                    height: 96,                       // 标题栏总高度 ↑
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(          // 上半部分：搜索框等
                          margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: Row(              // 搜索栏
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(    // 定位按钮（含右边距）
                                margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                width: 80,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Icon(Icons.location_on, size: 18),
                                      Container(
                                        child: Text(
                                          locatedCity,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        width: 62,
                                      )
                                    ],
                                  ),
                                  color: Colors.transparent,
                                  highlightColor: Color.fromARGB(127, 255, 217, 102),
                                  // splashColor: Colors.transparent,
                                  onPressed: (){
                                    print('点击了位置按钮');
                                  },
                                ),
                              ),
                              Container(    // 搜索框
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(96, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(999)
                                ),
                                padding: EdgeInsets.all(4),
                                width: MediaQuery.of(context).size.width - 12 - 80 - 4 - 4 - 48 - 12,
                                                          // 边距 定位按钮宽 左边距 右边距 动态按钮宽 边距
                                child: GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [BoxShadow(blurRadius: 8, spreadRadius: 4, color: Color.fromARGB(96, 255, 255, 255))]
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Icon(Icons.search, color: Colors.black87), margin: EdgeInsets.fromLTRB(8, 0, 6, 0)
                                          ),
                                        Text(
                                          '翻译/动态/景点',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54
                                          ),
                                          overflow: TextOverflow.clip),
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,  // 垂直居中
                                    ),
                                  ),
                                  onTap: () {
                                    // TODO
                                    print("点击了搜索框");
                                  },
                                ) 
                              ),
                              Container(    // 发动态按钮（含左边距）
                                margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                width: 48,
                                child: FlatButton(
                                  child: Icon(Icons.add_a_photo),
                                  padding: EdgeInsets.all(0),
                                  color: Colors.transparent,
                                  highlightColor: Color.fromARGB(127, 255, 217, 102),
                                  // splashColor: Colors.transparent,
                                  onPressed: () {
                                  //  Navigator.push( context, new MaterialPageRoute(
                                  //    builder: (context) { return new WritingPage(); },
                                  //    settings: RouteSettings( isInitialRoute: true ),
                                  //    maintainState: true
                                  //  ));
                                  print('点击了发布动态按钮');
                                  },
                                )
                              ),
                            ] 
                          ),
                        ),
                        Container(        // 下半部分：Tabs
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
                          // color: Color.fromARGB(127, 255, 255, 255),
                        )
                      ],
                    ),  
                  ),
                ),
              ),
            ) 
          ),
          body: TabBarView(
            children: tabpage
          ),
        ),
      ),
    );
  }
}


class DynamicsTile extends StatefulWidget {
  final String userNickName;
  final String avatarUrl;
  final String publishTime;
  final MyLatLng position;
  final String distance;
  final String likes;
  final String comments;
  final String content;
  final List<String> tags;
  final List<String> likerHeadIconUrls;
  final PublicVar publicVar;
  DynamicsTile({@required this.userNickName, @required this.avatarUrl, @required this.publishTime, @required this.position, this.distance, @required this.likes, @required this.comments, @required this.content, this.tags, this.likerHeadIconUrls, @required this.publicVar, Key key}) : super(key: key);
  @override
  DynamicsTileState createState() => new DynamicsTileState(this.userNickName, this.avatarUrl, this.publishTime, this.position, this.distance, this.likes, this.comments, this.content, this.tags == null ? <String>[] : this.tags, this.likerHeadIconUrls == null ? <String>[] : this.likerHeadIconUrls, this.publicVar);
}

class DynamicsTileState extends State<DynamicsTile> {
  final String userNickName;
  final String avatarUrl;
  final String publishTime;
  final MyLatLng position;
  final String distance;
        String likes;
  final String comments;
  final String content;
  final List<String> tags;
        List<String> likerHeadIconUrls;
        PublicVar publicVar;
  List<String> pictureList = [];
  Widget pictureBox;
        String trimmedContent;
  bool hasLiked = false;
  bool hasDisliked = false;

  DynamicsTileState(this.userNickName, this.avatarUrl, this.publishTime, this.position, this.distance, this.likes, this.comments, this.content, this.tags, this.likerHeadIconUrls, this.publicVar) {
    // 计算封面图像，消去文字内容中的图片标签
    int start = -1, end;
    String pictureAddress;
    trimmedContent = content + ' '; // 或许是 dart/flutter 的 bug，不加空格在 replaceRange 那里会报错
    do {
      start = trimmedContent.indexOf('![img](', start + 1);
      if (start > 0) {
        end = trimmedContent.indexOf(')', start + 1);
        pictureAddress = trimmedContent.substring(start + 7, end);
        if (pictureList.length < 3) {
          pictureList.add(pictureAddress);
        }
        trimmedContent = trimmedContent.replaceRange(start, end + 1, '');
      }
    } while (start != -1);
  }

  // 点👍操作
  void pressLike() {
    if (!hasLiked) {
      setState(() {
        hasLiked = true;
        likes = (int.parse(likes) + 1).toString();
        likerHeadIconUrls.add(publicVar.userAvatar);
      });
    }
  }

  // 点👎操作
  void pressDislike() {
    if (!hasDisliked) {
      setState(() {
        hasDisliked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tDynamicsTile: build()');

    // 计算点赞头像
    double likeButtonWidth = MediaQuery.of(context).size.width - 32 - 32 - 32 - 32 - 32 + 4;
    //         点赞按钮宽度 = 屏幕宽度 - Tile 左右边距 - 左右按钮边距 - 评论按钮宽度 - 评论数量宽度 - 差评按钮宽度
    int likeHeadIconsCount = (likeButtonWidth - 32 - 32) ~/ 20;
    
    List<Widget> likeHeadIcons = [];
    for (var url in likerHeadIconUrls) {
      likeHeadIcons.add(HeadIcon(url, 16, EdgeInsets.fromLTRB(2, 0, 2, 0)));
    }
    if (likeHeadIcons.length > likeHeadIconsCount) {
      likeHeadIcons = likeHeadIcons.sublist(0, likeHeadIconsCount);
    }

    // 计算封面图像
    switch (pictureList.length) {
      case 0:
        pictureBox = Image.asset('src/backgrounds/no_picture.png', fit: BoxFit.cover);
        break;
      case 1:
        pictureBox = Image.network(pictureList[0], fit: BoxFit.cover);
        break;
      case 2:
        pictureBox = Row(
          // mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(child: Image.network(pictureList[0], fit: BoxFit.cover, height: 120)),
            Expanded(child: Image.network(pictureList[1], fit: BoxFit.cover, height: 120))
          ]
        );
        break;
      case 3:
        pictureBox = Row(
          children: <Widget>[
            Expanded(child: Image.network(pictureList[0], fit: BoxFit.cover, height: 120)),
            Expanded(child: Image.network(pictureList[1], fit: BoxFit.cover, height: 120)),
            Expanded(child: Image.network(pictureList[2], fit: BoxFit.cover, height: 120))
          ]
        );
        break;
      default:
    }

    return Container(
      width: double.infinity,
      height: 220,
      // color: Colors.amber[100],
      margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),  // 外切圆角
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color.fromARGB(16, 0, 0, 0), blurRadius: 16, offset: Offset(0, 8)),
          BoxShadow(color: Colors.white, blurRadius: 4)
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),  // 内切圆角
        child: GestureDetector (
          onTap: () {
            Navigator.push( context, new MaterialPageRoute(
              builder: (context) { return new DynamicsDetail(
                userNickName: userNickName,
                avatarUrl: avatarUrl,
                publishTime: publishTime,
                position: position,
                distance: distance,
                content: content,
                comments: comments,
                likes: likes,
                likerHeadIconUrls: likerHeadIconUrls,
                tags: tags,
                publicVar: publicVar,
              );},
              settings: RouteSettings( isInitialRoute: true ),
              maintainState: true
            ));
          },
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 160,
              ),
              Positioned(             // 配图
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  child: pictureBox
                )
              ),
              Container(              // 图上阴影
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(80, 16, 16, 16),
                      Color.fromARGB(0, 16, 16, 16),
                      Color.fromARGB(0, 16, 16, 16)
                    ]
                  )
                ),
              ),
              Positioned(             // 左上角
                left: 8,
                top: 8,
                child: FlatButton(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: <Widget>[
                      HeadIcon(avatarUrl, 36),
                      SizedBox(width: 8),
                      Container(
                        height: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(       // 昵称
                              userNickName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: getHeightMutiply(24, 16, publicVar.lineHeightMultiply),
                                fontWeight: FontWeight.bold,
                                shadows: [BoxShadow(color: Color.fromARGB(64, 16, 16, 16), blurRadius: 3)]
                              ),
                            ),
                            Text(       // 时间
                              publishTime,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: getHeightMutiply(16, 12, publicVar.lineHeightMultiply),
                                shadows: [Shadow(color: Color.fromARGB(64, 16, 16, 16), blurRadius: 3)]
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  color: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Color.fromARGB(127, 255, 217, 102),
                  onPressed: () {},
                ) 
              ),
              Positioned(             // 右上角
                right: 12,
                top: 8,
                child: Container(
                  width: 88,
                  child: FlatButton(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(            // 上层位置
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.white70),
                            Text(
                              limitStringLengthByStyle(myLatLngToPlaceName(position), 64, TextStyle(fontSize: 12)),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white70)
                            )
                          ]
                        ),
                        SizedBox(height: 2),
                        Text(           // 下层距离
                          distance,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70
                          )
                        )
                      ],
                    ),
                    color: Colors.transparent,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    splashColor: Colors.transparent,
                    onPressed: (){
                      print('点击了动态位置按钮');
                    },
                  ),
                ),
              ),
              Positioned(             // 文章
                left: 16,
                right: 16,
                top: 128,
                child: Container(
                  // height: 58,
                  // color: Colors.redAccent,
                  child: Text(
                    trimmedContent,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      // height: (58 / 3) / (13 * publicVar.lineHeightMultiply),
                      height: getHeightMutiply(58 / 3, 13, publicVar.lineHeightMultiply),
                      letterSpacing: -0.2
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                )
              ),
              Positioned(             // 横线
                left: 8,
                right: 8,
                bottom: 32,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color.fromARGB(16, 0, 0, 0), Colors.transparent]
                    )
                  ),
                ),
              ),
              Positioned(             // 点赞
                left: 16,
                bottom: 0,
                child: Container(
                  height: 32,
                  width: likeButtonWidth,
                  child: FlatButton(
                    padding: EdgeInsets.all(4),
                    color: Colors.transparent,
                    splashColor: Colors.lime,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    onPressed: pressLike,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.thumb_up, color: hasLiked ? Colors.orange : Colors.black54, size: 16),
                        Container(
                          width: 32,
                          child: Text(
                            likes,
                            style: TextStyle(color: hasLiked ? Colors.orange : Colors.black54),
                            textAlign: TextAlign.center,
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: likeHeadIcons,
                        )
                      ],
                    ),
                  ),
                )
              ),
              Positioned(             // 评论
                right: 44,
                bottom: 0,
                child: Container(
                  height: 32,
                  width: 64,
                  child: FlatButton(
                    padding: EdgeInsets.all(4),
                    color: Colors.transparent,
                    splashColor: Colors.lime,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    onPressed: () {},
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          child: Text(
                            comments,
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          )
                        ),
                        Icon(Icons.comment, size: 16, color: Colors.black54),
                      ],
                    )
                  ) 
                )
              ),
              Positioned(             // 点差评
                right: 12,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  child: FlatButton(
                    padding: EdgeInsets.all(4),
                    color: Colors.transparent,
                    splashColor: Colors.lime,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    child: Icon(Icons.thumb_down, size: 16, color: hasDisliked ? Colors.orange : Colors.black54),
                    onPressed: pressDislike,
                  ),
                )
              ),
            ],
          ),
        ) 
      )
    );
  }
  
}