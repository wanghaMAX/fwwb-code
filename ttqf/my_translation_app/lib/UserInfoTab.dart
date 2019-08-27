import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'publicVariable.dart';

class UserInfoTab extends StatefulWidget {
  final PublicVar publicVar;
  UserInfoTab({@required this.publicVar, Key key}) : super(key: key);

  @override
  UserInfoTabState createState() => new UserInfoTabState(publicVar);
}

class UserInfoTabState extends State<UserInfoTab> {

  Dio dio = Dio();
  PersistCookieJar cookieJar;
  Options dioOptions = Options(
    connectTimeout: 2500,
    sendTimeout: 2000,
    receiveTimeout: 2000,
  );

  PublicVar publicVar;
  // 获取文档文件存储目录（存放 Cookies）
  UserInfoTabState(this.publicVar) {
    getDir();
  }
  void getDir() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(dir: appDocDir.path);
    dio.interceptors.add(CookieManager(cookieJar));
  }

  int followsCount = 0;
  int fansCount = 0;

  // 自定义弹出提示框
  void showMyPopup(String title, String content) {
    showCupertinoModalPopup(context: context, builder: (context) => AlertDialog(
      content: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          Container(height: 16),
          Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.25)),
        ],
        mainAxisSize: MainAxisSize.min,
      )
    ));
  }

  void todo() {
    showMyPopup('🙁肥肠抱歉🙁', '本功能未开发');
  }

  void changeUserAvatar() async {
    Response response;
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    List<int> imageData = image.readAsBytesSync();
    Options dioOptions = Options(
      connectTimeout: 2500,
      sendTimeout: 15000,
      receiveTimeout: 2000,
    );

    if (image != null) {
      try {
        response = await dio.post(
          "http://111.230.196.202:8085/image",
          options: dioOptions,
          data: {
            'format': getFileNameSuffix(image.uri.path),
            'image': base64Encode(imageData)
          }
        );
        List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/image'));
        for (Cookie cookie in cookies) {
          if (cookie.name == 'sessionid') {
            String sessionID = cookie.value;
            print("Updating avatar. sessionID: " + sessionID);
          }
        }

        String errStr = jsonDecode(response.data)['error'];
        if (errStr != '') {
          showMyPopup('😥发生了一些故障', errStr);
        } else {
          print(getFileNameSuffix(image.uri.path));
          String imageSha256 = sha256.convert(imageData).toString();
          changeUserInfo(avatar: imageSha256);
          setState(() {
           publicVar.userAvatar =  'http://111.230.192.202/images/' + imageSha256[0] + '/' + imageSha256[1] + '/' + imageSha256 + '.' + getFileNameSuffix(image.uri.path);
          });
        }

      } on DioError catch(e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if(e.response != null) {
          showMyPopup('😥发生了一些故障', "APP 跟服务器之间发生了一些文化差异，无法沟通了，尝试更新程序版本吧~\n${e.message}");
          print('Dio error with response.\nresponse data: ' + e.response.data + '\nresponse headers: ' + e.response.headers.toString() + "\n response request: " + e.response.request.toString());
        } else {
          print('Dio error with no response.');
          showMyPopup('😓啊哦，修改失败了', "无法连接到服务器\n${e.message}");
          // Something happened in setting up or sending the request that triggered an Error
          print(e.request);
          print(e.message);
        }  
      }
    }
  }

  void changeUserNickName() {
    showCupertinoDialog<String>(context: context, builder: (context) => AlertDialog(
      content: TextEditingDialog("编辑昵称", publicVar.userNickName, 32, false, null, null,
        onOKCallBack: (content) {
          setState(() {
            publicVar.userNickName = content;
          });
        },
      ),
      contentPadding: EdgeInsets.all(0),
    )).then((String result) {
      // print('result: ' + result);  // TextEditingDialog 一共有两种数据返回方式，这是退出弹窗后的返回
    });
  }

  void changeUserSignature() {
    showCupertinoDialog<String>(context: context, builder: (context) => AlertDialog(
      content: TextEditingDialog("编辑签名", publicVar.userSignature, 64, true, null, null,
        onOKCallBack: (content) {
          setState(() {
            publicVar.userSignature = content;
          });
        },
      ),
      contentPadding: EdgeInsets.all(0),
    ));
  }

  void changeUserMail() {
    showCupertinoDialog<String>(context: context, builder: (context) => AlertDialog(
      content: TextEditingDialog("编辑邮箱", publicVar.userMail, 64, false, TextInputType.emailAddress, '该邮箱为您的登录邮箱，请谨慎修改',
        onOKCallBack: (content) {
          setState(() {
            publicVar.userMail = content;
          });
        },
      ),
      contentPadding: EdgeInsets.all(0),
    ));
  }

  void changeUserPhone() {
    showCupertinoDialog<String>(context: context, builder: (context) => AlertDialog(
      content: TextEditingDialog("编辑电话号码", publicVar.userPhone, 24, false, TextInputType.phone, '该邮箱为您的登录电话号码，请谨慎修改',
        onOKCallBack: (content) {
          setState(() {
            publicVar.userPhone = content;
          });
        },
      ),
      contentPadding: EdgeInsets.all(0),
    ));
  }

  Future changeUserBirthday() async {
    List<String> birthdayArray = publicVar.userBirthday.split("-");
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(int.parse(birthdayArray[0]), int.parse(birthdayArray[1]), int.parse(birthdayArray[2])),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        publicVar.userBirthday = selectedDate.year.toString() + "-" + prefixZero(selectedDate.month, 2) + "-" + prefixZero(selectedDate.day, 2);
      });      
    }
  }

  // 更改任意类型的用户信息的网络部分
  void changeUserInfo({String username = '', String passwd = '', String sex = '', String avatar = '', String email = '', String phone = '', String birthday = '', String city = '', String stats = '', String privacy = ''}) async {
    
    Response response;

    try {
      response = await dio.post(
        "http://111.230.196.202:8085/updateInfo",
        options: dioOptions,
        data: {
          'username': username,
          'passwd': passwd,
          'sex': sex,
          'avatar': avatar,
          'email': email,
          'phone': phone,
          'birthday': birthday,
          'city': city,
          'stats': stats,
          'privacy': privacy
        }
      );
      List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/updateinfo'));
      for (Cookie cookie in cookies) {
        if (cookie.name == 'sessionid') {
          String sessionID = cookie.value;
          print("Changing user information. sessionID: " + sessionID);
        }
      }

      String errStr = jsonDecode(response.data)['error'];
      if (errStr != '') {
        showMyPopup('😥发生了一些故障', errStr);
      } else {

      }

    } on DioError catch(e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if(e.response != null) {
        showMyPopup('😥发生了一些故障', "APP 跟服务器之间发生了一些文化差异，无法沟通了，尝试更新程序版本吧~\n${e.message}");
        print('Dio error with response.\nresponse data: ' + e.response.data + '\nresponse headers: ' + e.response.headers.toString() + "\n response request: " + e.response.request.toString());
      } else {
        print('Dio error with no response.');
        showMyPopup('😓啊哦，注册失败了', "无法连接到服务器\n${e.message}");
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }  
    }
    

  }

  @override
  Widget build(BuildContext context) {
    print(new DateTime.now().toString() + '\tUserInfoTab: build()');

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 210,
            child: Stack(
              children: <Widget>[
                Image.asset(
                  'src/backgrounds/user_pwall_default.png',
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                Align(                                // 关注
                  alignment: Alignment(-0.8, -0.4),
                  child: FlatButton(
                    color: Colors.transparent,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    // splashColor: Colors.transparent,
                    shape: CircleBorder(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 16),
                        Text(
                          '关注',
                          style: TextStyle(
                            fontSize: 14,
                            shadows: <Shadow>[
                              Shadow(blurRadius: 3, color: Colors.white)
                            ]
                          )
                        ),
                        Text(
                          followsCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.25,
                            color: Colors.orange,
                            shadows: <Shadow>[
                                Shadow(blurRadius: 1.5, color: Colors.white),
                                Shadow(color: Color.fromARGB(64, 200, 0, 255), blurRadius: 3, offset: Offset(0, 2))
                              ]
                            )
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                    onPressed: (){
                      todo();
                    },
                  ),
                ),
                Align(                                // 粉丝
                  alignment: Alignment(0.8, -0.4),
                  child: FlatButton(
                    color: Colors.transparent,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    // splashColor: Colors.transparent,
                    shape: CircleBorder(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 16),
                        Text(
                          '粉丝',
                          style: TextStyle(
                            fontSize: 14,
                            shadows: <Shadow>[
                              Shadow(blurRadius: 3, color: Colors.white)
                            ]
                          )
                        ),
                        Text(
                          fansCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.25,
                            color: Colors.orange,
                            shadows: <Shadow>[
                                Shadow(blurRadius: 1.5, color: Colors.white),
                                Shadow(color: Color.fromARGB(64, 200, 0, 255), blurRadius: 3, offset: Offset(0, 2))
                              ]
                            )
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                    onPressed: (){
                      showCupertinoModalPopup(context: context, builder: (context) => AlertDialog(
                        content: Column(
                          children: <Widget>[
                            Text('🙁肥肠抱歉🙁', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                            Container(height: 16),
                            Text('本功能未开发', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45)),
                          ],
                          mainAxisSize: MainAxisSize.min,
                        )
                      ));
                    },
                  ),
                ),
                Align(                                // 头像
                  alignment: Alignment(0, -0.9),
                  child: Container(
                    width: 128,
                    height: 128,
                    child: FlatButton(
                      color: Colors.transparent,
                      highlightColor: Color.fromARGB(127, 255, 217, 102),
                      splashColor: Colors.transparent,
                      shape: CircleBorder(),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(spreadRadius: 1, color: Colors.white),
                            BoxShadow(blurRadius: 4, color: Color.fromARGB(32, 0, 0, 0), offset: Offset(0, 3))
                          ]
                        ),
                        child: HeadIcon(publicVar.userAvatar),
                      ),
                      onPressed: (){
                        changeUserAvatar();
                      },
                    ),
                  ),                          
                ),
                Align(                                // 昵称
                  alignment: Alignment(0, 0.45),
                  child: FlatButton(
                    color: Colors.transparent,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    // splashColor: Colors.transparent,
                    child: Text(
                      publicVar.userNickName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600,
                        shadows: <Shadow>[
                          Shadow(blurRadius: 3, color: Colors.white)
                        ]
                      ),
                    ),
                    onPressed: (){
                      changeUserNickName();
                    },
                  ),

                ),
                Align(                                // 签名
                  alignment: Alignment(0, 0.9),
                  child: FlatButton(
                    color: Colors.transparent,
                    highlightColor: Color.fromARGB(127, 255, 217, 102),
                    // splashColor: Colors.transparent,
                    child: Text(
                      publicVar.userSignature,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        shadows: <Shadow>[
                          Shadow(blurRadius: 2, color: Colors.white)
                        ]
                      ),
                    ),
                    onPressed: (){
                      changeUserSignature();
                    },
                  ),
                ),               
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(                           // 收藏
                color: Colors.transparent,
                highlightColor: Color.fromARGB(127, 255, 217, 102),
                // splashColor: Colors.transparent,
                shape: CircleBorder(),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    Image.asset(
                      'src/icons/collection.png',
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      '收藏',
                      style: TextStyle(height: 1.5, color: Colors.black87)
                    ),
                    SizedBox(height: 8)
                  ],
                ),
                onPressed: (){
                  todo();
                },
              ),
              FlatButton(                           // 历史
                color: Colors.transparent,
                highlightColor: Color.fromARGB(127, 255, 217, 102),
                // splashColor: Colors.transparent,
                shape: CircleBorder(),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    Image.asset(
                      'src/icons/history.png',
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      '历史',
                      style: TextStyle(height: 1.5, color: Colors.black87)
                    ),
                    SizedBox(height: 8)
                  ],
                ),
                onPressed: (){
                  todo();
                },
              ),
              FlatButton(                           // 消息
                color: Colors.transparent,
                highlightColor: Color.fromARGB(127, 255, 217, 102),
                // splashColor: Colors.transparent,
                shape: CircleBorder(),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    Image.asset(
                      'src/icons/message.png',
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      '消息',
                      style: TextStyle(height: 1.5, color: Colors.black87)
                    ),
                    SizedBox(height: 8)
                  ],
                ),
                onPressed: (){
                  todo();
                },
              ),
            ],
          ),
          MyListTile('性别', publicVar.userSex, (){ print('点击了“性别”'); }),
          MyListTile('生日', publicVar.userBirthday, (){ changeUserBirthday(); }),
          MyListTile('故乡', publicVar.userCity, (){ print('点击了“故乡”'); }),
          MyListTile('登录邮箱', publicVar.userMail, (){ changeUserMail(); }),
          MyListTile('登录手机', publicVar.userPhone, (){ changeUserPhone(); }),
          MyListTile('修改密码', '', (){ print('点击了“修改密码”'); }),
          SizedBox(height: 64)
        ],
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  final String string_left;
  final String string_right;
  final Function onTapCallback;
  MyListTile(this.string_left, this.string_right, this.onTapCallback);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.transparent,
      highlightColor: Color.fromARGB(127, 255, 217, 102),
      splashColor: Colors.lime,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(string_left, textAlign: TextAlign.left),
            Text(string_right, textAlign: TextAlign.right, style: TextStyle(color: Colors.black54), overflow: TextOverflow.fade),
          ],
        ),
      ),
      onPressed: (){ onTapCallback(); }
    );
  }
}