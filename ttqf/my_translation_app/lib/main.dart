import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'publicVariable.dart';
import 'loginPage.dart';
import 'testPage.dart';

void main() {
  runApp(MyApp());
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor:Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}


/* 应用程序入口 */
class MyApp extends StatelessWidget {

  static String myVar = "hi";
    
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '中日驿',
      home: new LoginPage(publicVar: new PublicVar(
        userAvatar: 'http://backupserver.tencent.ttqf.tech/useravatar/20180908%20%E5%A4%B4%E5%83%8F.JPG',
        userNickName: '前端滔滔清风',
        userSignature: "这家伙很懒，什么都没有开发",
        userSex: '男',
        userBirthday: '2000-00-00',
        userCity: '不存在市',
        userMail: 'pacteradxteam@gmail.com',
        userPhone: 'pacteradx0411',
        lineHeightMultiply: 1.0
      )),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 252, 201, 45),
        splashColor: Colors.white,
        highlightColor: Color.fromARGB(255, 255, 217, 102),
        buttonColor: Color.fromARGB(255, 252, 201, 45),
      ),
    );
  }
}
