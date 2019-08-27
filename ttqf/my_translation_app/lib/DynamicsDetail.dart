import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'publicVariable.dart';

class DynamicsDetail extends StatefulWidget {
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
  DynamicsDetail({@required this.userNickName, @required this.avatarUrl, @required this.publishTime, @required this.position, @required this.distance, @required this.likes, @required this.comments, @required this.content, this.tags, this.likerHeadIconUrls, @required this.publicVar, Key key}) : super(key: key);
  
  @override
  DynamicsDetailState createState() => new DynamicsDetailState(this.userNickName, this.avatarUrl, this.publishTime, this.position, this.distance, this.likes, this.comments, this.content, this.tags == null ? <String>[] : this.tags, this.likerHeadIconUrls == null ? <String>[] : this.likerHeadIconUrls, this.publicVar);
}

class DynamicsDetailState extends State<DynamicsDetail> {
  final String userNickName;
  final String avatarUrl;
  final String publishTime;
  final MyLatLng position;
  final String distance;
        String likes;
  final String comments;
        String content;
  final List<String> tags;
        List<String> likerHeadIconUrls;
  final PublicVar publicVar;
  List<Widget> contentList = [];
  bool hasLiked = false;
  bool hasDisliked = false;

  DynamicsDetailState(this.userNickName, this.avatarUrl, this.publishTime, this.position, this.distance, this.likes, this.comments, this.content, this.tags, this.likerHeadIconUrls, this.publicVar) {

    contentList.add( 
      Container(              // 地图标题栏
        width: double.infinity,
        height: 200,
        child: Stack(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 200,
            ),
            GoogleMapWrapper(position),
            Container(              // 图上阴影
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(0, 250, 250, 250),
                    Color.fromARGB(0, 250, 250, 250),
                    Color.fromARGB(80, 250, 250, 250),
                    Color.fromARGB(255, 250, 250, 250),
                  ]
                )
              ),
            ),
            Positioned(             // 左下角
              left: 8,
              bottom: 8,
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
                              color: Colors.black,
                              fontSize: 16,
                              height: getHeightMutiply(24, 16, publicVar.lineHeightMultiply),
                              fontWeight: FontWeight.bold,
                              shadows: [BoxShadow(color: Colors.white, blurRadius: 3)]
                            ),
                          ),
                          Text(       // 时间
                            publishTime,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              height: getHeightMutiply(16, 12, publicVar.lineHeightMultiply),
                              shadows: [Shadow(color: Colors.white70, blurRadius: 3)]
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
            Positioned(             // 右下角
              right: 12,
              bottom: 8,
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
                          Icon(Icons.location_on, size: 14, color: Colors.black87),
                          Text(
                            limitStringLengthByStyle(myLatLngToPlaceName(position), 64, TextStyle(fontSize: 12)),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black87)
                          )
                        ]
                      ),
                      SizedBox(height: 2),
                      Text(           // 下层距离
                        distance,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87
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
          ],
        )
      )
    );
    contentList.add(SizedBox(height: 20));

    // 计算图像块和文字块
    int start = -1, end;              // 图像标签的起始和结束
    String textContent;
    String pictureAddress;
    content += " ";                   // 或许是 dart/flutter 的 bug，不加空格在 replaceRange 那里会报错
    while (textContent != ' ') {
      textContent = pictureAddress = '';
      start = content.indexOf('![img](', 0);
      if (start > 0) {                // 有图片，但图片前还有一段文字
        textContent = content.substring(0, start);
        content = content.substring(start);
      } else if (start == 0) {        // 接下来就是图片
        end = content.indexOf(')', start + 1);
        pictureAddress = content.substring(start + 7, end);
        content = content.substring(end + 1);
      } else {                        // 没图了
        textContent = content;
      }

      if (textContent != '' && textContent != ' ') { // 添加文字块
        contentList.add(Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Text(
            textContent,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87
            )
          ),
        ));
      } else if (pictureAddress != '') {  // 添加图块
        contentList.add(ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300, minWidth: double.infinity),
          child: Image.network(
            pictureAddress,
            fit: BoxFit.contain
          ),
        ));
      }
    }

    contentList.add(SizedBox(height: 20));
    contentList.add(LikeAndCommentModule(likes: likes, comments: comments, likerHeadIconUrls: likerHeadIconUrls, publicVar: publicVar));

  }

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tDynamicsDetail: build()');
    
    for (var x in contentList) {
      print(x);
    }
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(54),       // 标题栏总高度 ↓
        child: Container(         // 整个标题栏的阴影
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 8, color: Color.fromARGB(32, 96, 64, 0))]
          ),
          child: AppBar(
            automaticallyImplyLeading: true,
            elevation: 0,
            titleSpacing: 0,
            centerTitle: true,
            flexibleSpace: Image.asset('src/backgrounds/title_bg.png', fit: BoxFit.cover),
            title: Text('动态详情', style: TextStyle(fontSize: 18)),
            backgroundColor: Colors.transparent,
          ),
        )
      ),
      body: ListView(
        children: contentList,
      ),
    );
  }
}


/// 点👍👎评论模块，独立起来用于避免放在上面没法刷新的问题
class LikeAndCommentModule extends StatefulWidget {
  final String likes;
  final String comments;
  final List<String> tags;
  final List<String> likerHeadIconUrls;
  final PublicVar publicVar;
  LikeAndCommentModule({@required this.likes, @required this.comments, this.tags, @required this.likerHeadIconUrls, @required this.publicVar, Key key}) : super(key: key);
  
  @override
  LikeAndCommentModuleState createState() => new LikeAndCommentModuleState(this.likes, this.comments, this.tags, this.likerHeadIconUrls, this.publicVar);
}

class LikeAndCommentModuleState extends State<LikeAndCommentModule> {
        String likes;
  final String comments;
  final List<String> tags;
        List<String> likerHeadIconUrls;
  final PublicVar publicVar;
  bool hasLiked = false;
  bool hasDisliked = false;

  LikeAndCommentModuleState(this.likes, this.comments, this.tags, this.likerHeadIconUrls, this.publicVar);

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
    
    // 计算点赞头像
    double likeButtonWidth = MediaQuery.of(context).size.width - 32 - 32 - 32 - 32;
    //         点赞按钮宽度 = 屏幕宽度 - 页面左右边距 - 评论按钮宽度 - 评论数量宽度 - 差评按钮宽度
    int likeHeadIconsCount = (likeButtonWidth - 32 - 32) ~/ 20;
    
    List<Widget> likeHeadIcons = [];
    for (var url in likerHeadIconUrls) {
      likeHeadIcons.add(HeadIcon(url, 16, EdgeInsets.fromLTRB(2, 0, 2, 0)));
    }
    if (likeHeadIcons.length > likeHeadIconsCount) {
      likeHeadIcons = likeHeadIcons.sublist(0, likeHeadIconsCount);
    }

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: <Widget>[
              Container(              // 点👍
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
              ),
              Container(              // 评论
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
                  ),
              Container(              // 点👎
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
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '评论',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '这里相当安静哦，静心欣赏下风景吧\nここはとても静かで、心を静めて眺めてみましょう',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.5
            ),
            textAlign: TextAlign.center,
          ),
        ),

      ],
    ) ;
  }

}

class GoogleMapWrapper extends StatelessWidget {
  final MyLatLng position;
  
  GoogleMapWrapper(this.position);
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16.0
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        print('mapCreated');
      },
      myLocationEnabled: true,
    );
  }
}