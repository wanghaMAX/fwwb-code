import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';


final String YOUDAO_URL = "http://openapi.youdao.com/asrapi";
final String APP_KEY = "4d824041615e3f15";
final String APP_SECRET = "tWXn8ggBLsh8APsMwAdoumLANjvBxYYe";

String filePath = "/storage/emulated/0/testrr.wav";

var voiceFile = File(filePath);

String q = '';
String langType;
String appKey = APP_KEY;
String salt;
String sign;
String format = 'wav';
String rate = '16000';
String channel = '1';
String type = '1';

Map<String, String> pragma;

cnToJaResultGet() async{
  try{
    print(filePath);
    langType = 'zh-CHS';
    salt = Random().nextInt(100000000).toString();

    try {
      bool exists = voiceFile.existsSync();
      if (!exists) {
        debugPrint("not exist");
        voiceFile.createSync();
      }else{
        q = base64Encode(voiceFile.readAsBytesSync());
        debugPrint("get"+q);
      }
    } catch (e) {
      debugPrint("000000000000");
      print(e);
    }

    sign = md5.convert(utf8.encode(appKey + q + salt + APP_SECRET)).toString();

    FormData pragma = FormData.from({
      "q": q,
      "langType": langType,
      "appKey": appKey,
      "salt": salt,
      "sign": sign,
      "format": format,
      "rate": rate,
      "channel": channel,
      "type": type
    });
    Response response;
    Dio ctjDio = new Dio();
    debugPrint("test1");
    response = await ctjDio.post(YOUDAO_URL, data: pragma);
    debugPrint("test2");
    debugPrint(response.toString());
    Map receive = response.data;
    debugPrint(receive.toString());
    debugPrint("88888888888888888");
    if (response.statusCode == 200) {
      print("88888888888888888");
      print("111" + receive.toString());
      print("222" + receive["errorcode"]);
      print("333" + receive["result"]);
    }else{
      debugPrint(response.statusCode.toString());
    }
  }catch(e){
    print(e);
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our App',
      theme: ThemeData(primaryColor: Colors.blueAccent),
      home: Homepage(),
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.blue,
          child: Text('Try'),
          onPressed: () {
            setData() async {
              debugPrint("8888888888888");
              await cnToJaResultGet();
              debugPrint("666666666666");
            }
            setData();
          },
        ),
      ),
    );
  }
}