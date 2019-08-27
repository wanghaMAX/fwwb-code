import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'dart:convert';  // for the utf8.encode method and json decode
// import 'dart:_http';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'publicVariable.dart';
import 'MainPage.dart';

class LoginPage extends StatefulWidget {
  final PublicVar publicVar;
  LoginPage({@required this.publicVar, Key key}) : super(key: key);

  @override
  LoginPageState createState() => new LoginPageState(publicVar);
}

class LoginPageState extends State<LoginPage> {

  Dio dio = Dio();
  PersistCookieJar cookieJar;
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  FocusNode secondTextFieldNode = FocusNode();

  // 获取文档文件存储目录（存放 Cookies）
  PublicVar publicVar;
  LoginPageState(this.publicVar) {
    getDir();
  }
  void getDir() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(dir: appDocDir.path);
  }

  String sessionID = "";
  String salt = "";
  Options dioOptions = Options(
    connectTimeout: 2500,
    sendTimeout: 15000,
    receiveTimeout: 2000,
  );


  // 密码加密
  String passwordEncode(String password, String salt, String sessionID, bool isLogin) {
    final String sha256edPassword = sha256.convert(utf8.encode(password)).toString();
    // 加密方式：sha256(salt + sha256(passwd).toHexString() + sessionId).toHexString()
    if (isLogin) {
      final List<int> encodingPasswordStep1 = utf8.encode(salt + sha256edPassword + sessionID);
      return sha256.convert(encodingPasswordStep1).toString();
    } else {
      return sha256edPassword;
    }
  }
  
  // 登录验证
  void loginVerify({bool isGuest = false}) async {
    
    Response response;
    String sessionID = "";
    String salt = "";

    if (usernameCtrl.text == "") {
      showMyPopup('🚶请填写用户名哟 (｢･ω･)｢', '登陆后我就能为你推荐当地的特色了呢~');
    } else if (usernameCtrl.text.length < 4) {
      showMyPopup('🤔用户名格式不对🤔', '不能少于 4 位');
    } else if (passwordCtrl.text == "") {
      showMyPopup('🚶请填写密码哟 (｢･ω･)｢', '登陆后我就能为你推荐当地的特色了呢~');
    } else if (passwordCtrl.text.length < 8) {
      showMyPopup('🤔密码格式不对🤔', '不能少于 8 位');
    } else {

      try {
        cookieJar.deleteAll();
        dio.interceptors.add(CookieManager(cookieJar));
        // 首先获取 sessionID，这种加密方式详见百科 hmac
        response = await dio.get(
          "http://111.230.196.202:8085/login",
          options: dioOptions
        );
        List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login'));
        for (Cookie cookie in cookies) {
          if (cookie.name == 'sessionid') {
            sessionID = cookie.value;
            print("Logining. sessionID: " + sessionID);
          }
        }
        // String setCookie = response.headers['set-cookie'][0];
        // sessionID = setCookie.substring(10, 42);
        Map<String, dynamic> responseData = jsonDecode(response.data)['data'];
        salt = responseData['salt'];
        // print("sessionID: " + sessionID);
        print("salt: " + salt);
        
        String encodedPassword = passwordEncode(passwordCtrl.text, salt, sessionID, true);
        
        response = await dio.post(
          "http://111.230.196.202:8085/login",
          data: {
            'name': usernameCtrl.text,
            'passwd': encodedPassword
          },
          options: Options(
            connectTimeout: 1500,
            sendTimeout: 1000,
            receiveTimeout: 1000,
            // cookies: Iterable<Cookie>.generate(1, (int i) => Cookie.fromSetCookieValue(setCookie))
            // cookies: cookieJar.loadForRequest(Uri.parse("http://111.230.196.202/"))
          )
        );
        cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login'));
        for (Cookie cookie in cookies) {
          if (cookie.name == 'sessionid') {
            sessionID = cookie.value;
            print("Logining. sessionID: " + sessionID);
          }
        }
        String errStr = jsonDecode(response.data)['error'];
        if (errStr == "no such user") {
          // 进入注册
          register(usernameCtrl.text, passwordCtrl.text, isGuest: isGuest);
        } else if (errStr == "password incorrect") {
          showMyPopup("😥啊哦，手滑了", '密码不对哦');
        } else if (errStr != "") {
          // showMyPopup("😥发生了一些故障", '${errStr}');
          showMyPopup("😥发生了一些故障", errStr);
        } else {
          // 登录成功
          cookieJar.saveFromResponse(Uri.parse('http://111.230.196.202:8085/'), cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login')));
          showMyPopup("🙋‍欢迎使用", '登录成功');
          Future.delayed(Duration(milliseconds: 100), () {
            publicVar.sessionID = sessionID;
            jumpToMain(username: usernameCtrl.text);
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
          showMyPopup('😓啊哦，登录失败了', "无法连接到服务器\n${e.message}");
          // Something happened in setting up or sending the request that triggered an Error
          print(e.request);
          print(e.message);
        }  
      }
    }
  }

  void register(String username, String password, {bool isGuest = false}) async {
    
    Response response;

    Map<String, dynamic> regData = {
      'username': username,
      'passwd': passwordEncode(password, null, null, false),
      'sex': '',
      'email': '',
      'phone': '',
      'birthday': '',
      'city': '',
      'stats': ''
    };
    bool cancel = false;
    if (!isGuest) {
      await showCupertinoDialog<String>(context: context, builder: (context) => AlertDialog(
        content: TextEditingDialog("您正在注册新用户", "", 32, false, null, "填入邮箱或电话号码，完成注册（可留空）",
          onOKCallBack: (content) {
            regData['email'] = content.indexOf('@') > 0 ? content : '';
            regData['phone'] = content.length > 0 && !content.contains('@') ? content : '';
          },
          onCancelCallBack: (content) {
            cancel = true;
          },
        ),
        contentPadding: EdgeInsets.all(0),
      )).then((String result) {
        // print('result: ' + result);  // TextEditingDialog 一共有两种数据返回方式，这是退出弹窗后的返回
      });
    }
    if (cancel) return;
    // print('passwordEncoded: ' + passwordEncode(password, null, null, false));
    try {
      response = await dio.post(
        "http://111.230.196.202:8085/register",
        options: dioOptions,
        data: regData
      );
      List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/register'));
      for (Cookie cookie in cookies) {
        if (cookie.name == 'sessionid') {
          sessionID = cookie.value;
          print("Registering. sessionID: " + sessionID);
        }
      }
      String errStr = jsonDecode(response.data)['error'];
      if (errStr != '') {
        showMyPopup('😥发生了一些故障', "APP 跟服务器之间发生了一些文化差异，无法沟通了，尝试更新程序版本吧~\n" + errStr);
      } else {
        // 注册并登录成功
        cookieJar.saveFromResponse(Uri.parse('http://111.230.196.202:8085/'), cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/register')));
        showMyPopup("🙋‍欢迎使用", '新用户 ' + usernameCtrl.text + ' 注册成功');
        Future.delayed(Duration(milliseconds: 1500), () {
          publicVar.sessionID = sessionID;
          jumpToMain(username: username);
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
        showMyPopup('😓啊哦，注册失败了', "无法连接到服务器\n${e.message}");
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }  
    }
  }

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

  // 产生随机用户名
  String randomHexString(int length) {
    String _temp = "";
    const String alphabet = "0123456789abcdef";
    for(int n = 0; n <= length; n++) {
      _temp += alphabet[Random().nextInt(15)];
    }
    return _temp;
  }

  // 跳转到主页
  void jumpToMain({String username}) async {

    Response response;

    if (username != null) {
      try {
        response = await dio.post(
          "http://111.230.196.202:8085/userinfo",
          options: dioOptions,
          data: {
            'username': username
          }
        );
        List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse('http://111.230.196.202:8085/userinfo'));
        for (Cookie cookie in cookies) {
          if (cookie.name == 'sessionid') {
            sessionID = cookie.value;
            print("Jumping to main page. sessionID: " + sessionID);
          }
        }

        String errStr = jsonDecode(response.data)['error'];
        if (errStr != '') {
          showMyPopup('😥发生了一些故障', errStr);
        } else {
          // 获取用户信息
          Map<String, dynamic> userData = jsonDecode(response.data)['data'];
          publicVar.userNickName = userData['username'];
          publicVar.userSex = userData['sex'];
          publicVar.userAvatar = userData['avatar'];
          publicVar.userMail = userData['email'];
          publicVar.userPhone = userData['phone'];
          publicVar.userBirthday = userData['birthday'];
          publicVar.userCity = userData['city'];
          publicVar.userSignature = userData['stats'];
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
    publicVar.lineHeightMultiply = testtextKey.currentContext.size.height / 40.0;
    // print(publicVar.lineHeightMultiply);
    Navigator.push( context, new MaterialPageRoute(
      builder: (context) { return new MainPage(publicVar: publicVar); },
      settings: RouteSettings( isInitialRoute: true ),
      maintainState: false
    ));
  }

  GlobalKey testtextKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
        
    return Scaffold(
      body: Stack(
          children: <Widget>[
            Image.asset(                      // 背景
              'src/backgrounds/login.jpg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Opacity(                          // 用于计算行高的全透明 Widget
              opacity: 0,
              child: Text(
                '一a',
                key: testtextKey,
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
            Align(                            // 中间内容
              alignment: Alignment(0, -0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(height: 30),
                  Container(
                    width: 300,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '开始你的旅行', style: TextStyle( color: Colors.black87, fontSize: 36, fontWeight: FontWeight.w800 )),
                          TextSpan(text: '\n\n马上登录/注册，享受畅通愉快的旅行。', style: TextStyle( color: Colors.black45, fontSize: 14 ))
                        ]
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 340,
                    child: TextField(
                      controller: usernameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: '用户名',
                        hintText: '已有账号/新建账号',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 18),
                      onEditingComplete: () => FocusScope.of(context).requestFocus(secondTextFieldNode),
                      
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 340,
                    child: TextField(
                      controller: passwordCtrl,
                      focusNode: secondTextFieldNode,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: '密码',
                        hintText: '已有帐号密码/新建账号密码',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 18),
                      obscureText: true       // 小圆点显示
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 200,
                    child: RaisedButton(
                      onPressed: () {loginVerify();},
                      child: Text('登录/注册', style: TextStyle(color: Colors.white)),
                      elevation: 0.0,
                      highlightElevation: 0.0,
                    )
                  ),
                  Container(
                    width: 200,
                    child: RaisedButton(
                      onPressed: () {
                        usernameCtrl.text = "guest_" + randomHexString(8);
                        passwordCtrl.text = "00000000";
                        loginVerify(isGuest: true);
                      },
                      child: Text('👦 先不登录，进来逛逛 👧', style: TextStyle(color: Colors.white)),
                      elevation: 0.0,
                      highlightElevation: 0.0,
                      color: Colors.grey,
                      highlightColor: Colors.lime,
                    )
                  )
                ],
              ) 
            ),
            Positioned(                       // 软件图标
              top: MediaQuery.of(context).size.height * 0.85,
              left: MediaQuery.of(context).size.width / 2 - 160 / 2,
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    child: Image.asset('src/icons/appicon_with_word.png', width: 160),
                    onTap: () {
                      // showMyPopup('开发者模式！', '免登录调试');
                      // Scaffold.of(context).showSnackBar(
                      //   SnackBar(content: new Text('开发者模式！'))
                      // );
                      jumpToMain();
                    },
                  );
                }
              )
            ),
          ],
        ),
    );
  }

}
