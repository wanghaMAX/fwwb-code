import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'flutterSound.dart';

List<Widget> voiceTranslateView = List();
var textTranslateSoundController = FlutterSound();
Map ctjReceiveData = {
  "tSpeakUrl":
      "http://openapi.youdao.com/ttsapi?q=%E3%81%93%E3%82%8C%E3%81%AF%E3%81%84%E3%81%8F%E3%82%89%E3%81%A7%E3%81%99%E3%81%8B%E3%80%82%EF%BC%9F&langType=ja&sign=225A02977FDCDD171C5E16BAC4C9CBFB&salt=1553690725342&voice=0&format=mp3&appKey=705ca7cd1e9cce30"};
Map jtcReceiveData = {
  "tSpeakUrl":
      "http://openapi.youdao.com/ttsapi?q=%E4%BD%A0%E5%A5%BD%E3%80%82&langType=zh-CHS&sign=049150974B92B7EA448E551210374377&salt=1553690643007&voice=0&format=mp3&appKey=705ca7cd1e9cce30"};

void soundOut (String path)async{
  try{
    int changeNum = 0;
    if (path.toString().isNotEmpty) {
      if (changeNum % 2 == 0) {
        textTranslateSoundController
            .startPlayer(path);
      } else {
        if (textTranslateSoundController.isPlaying) {
          textTranslateSoundController.stopPlayer();
        } else {
          textTranslateSoundController
              .startPlayer(path);
          changeNum++;
        }
      }
      changeNum++;
    }
  }catch(e){}
}

final String YOUDAO_URL_TEXT = "http://openapi.youdao.com/api";
final String APP_KEY_TEXT = "705ca7cd1e9cce30";
final String APP_SECRET_TEXT = "Rt2TwJG13WTaAHhJoQXOHqVgFXUVMUv7";

String textQ = "";
String textCurtime;
String textSalt;
String textSIGN;
String textSign;
Map<String, String> textPragma;

cnToJaTextResultGet() async {
  try {
    textSalt = Random().nextInt(100000000).toString();
    textCurtime =
        ((DateTime.now().millisecondsSinceEpoch / 1000).round()).toString();
    if (textQ.length <= 20) {
      textSIGN =
          APP_KEY_TEXT + textQ + textSalt + textCurtime + APP_SECRET_TEXT;
      textSign = sha256.convert(utf8.encode(textSIGN)).toString();
    } else {
      textSIGN = APP_KEY_TEXT +
          textQ.substring(0, 10) +
          textQ.length.toString() +
          textQ.substring(textQ.length - 10, textQ.length) +
          textSalt +
          textCurtime +
          APP_SECRET_TEXT;
      textSign = sha256.convert(utf8.encode(textSIGN)).toString();
    }
    textPragma = {
      "q": textQ,
      "from": "zh-CHS",
      "to": "ja",
      "voice": "0",
      "appKey": APP_KEY_TEXT,
      "salt": textSalt,
      "curtime": textCurtime,
      "sign": textSign,
      "signType": "v3"
    };

    Response response;
    Dio ctjDio = new Dio();
    response = await ctjDio.get(YOUDAO_URL_TEXT, queryParameters: textPragma);
    if (response.statusCode == 200) {
      return response.data;
    }
  } catch (e) {}
}

jaToCnTextResultGet() async {
  try {
    textSalt = Random().nextInt(100000000).toString();
    textCurtime =
        ((DateTime.now().millisecondsSinceEpoch / 1000).round()).toString();
    if (textQ.length <= 20) {
      textSIGN =
          APP_KEY_TEXT + textQ + textSalt + textCurtime + APP_SECRET_TEXT;
      textSign = sha256.convert(utf8.encode(textSIGN)).toString();
    } else {
      textSIGN = APP_KEY_TEXT +
          textQ.substring(0, 10) +
          textQ.length.toString() +
          textQ.substring(textQ.length - 10, textQ.length) +
          textSalt +
          textCurtime +
          APP_SECRET_TEXT;
      textSign = sha256.convert(utf8.encode(textSIGN)).toString();
    }
    textPragma = {
      "q": textQ,
      "from": "ja",
      "to": "zh-CHS",
      "voice": "0",
      "appKey": APP_KEY_TEXT,
      "salt": textSalt,
      "curtime": textCurtime,
      "sign": textSign,
      "signType": "v3"
    };
    Response response;
    Dio jtcDio = new Dio();
    response = await jtcDio.get(YOUDAO_URL_TEXT, queryParameters: textPragma);
    if (response.statusCode == 200) {
      return response.data;
    }
  } catch (e) {}
}

final String YOUDAO_URL_VOICE = "http://openapi.youdao.com/asrapi";
final String APP_KEY_VOICE = "4d824041615e3f15";
final String APP_SECRET_VOICE = "tWXn8ggBLsh8APsMwAdoumLANjvBxYYe";

String filePath = "/storage/emulated/0/testrr.wav";
var voiceFile = File(filePath);
String voiceQ = "";
String voiceSalt;
String voiceSign;
Map<String, String> voicePragma;

cnToJaVoiceResultGet() async {
  try {
    print(filePath);
    try {
      bool exists = voiceFile.existsSync();
      if (!exists) {
        debugPrint("not exist");
        voiceFile.createSync();
      } else {
        voiceQ = base64Encode(voiceFile.readAsBytesSync());
        debugPrint("get" + voiceQ);
      }
    } catch (e) {
      debugPrint("000000000000");
      print(e);
    }
    voiceSalt = Random().nextInt(100000000).toString();
    voiceSign = md5
        .convert(
            utf8.encode(APP_KEY_VOICE + voiceQ + voiceSalt + APP_SECRET_VOICE))
        .toString();
    voicePragma = {
      "q": voiceQ,
      "langType": "zh-CHS",
      "appKey": APP_KEY_VOICE,
      "salt": voiceSalt,
      "sign": voiceSign,
      "format": "wav",
      "rate": "16000 ",
      "channel": "1",
      "type": "1",
    };

    Response response;
    Dio ctjDio = new Dio();
    response = await ctjDio.post(YOUDAO_URL_VOICE, data: voicePragma);
    Map receive = response.data;
    if (response.statusCode == 200) {
      if (receive["errorCode"] == "") {
        textQ = receive["result"];
        Map result = await cnToJaTextResultGet();
        return result;
      } else {
        return "error";
      }
    }
  } catch (e) {}
}

jaToCnVoiceResultGet() async {
  try {
    print(filePath);
    try {
      bool exists = voiceFile.existsSync();
      if (!exists) {
        debugPrint("not exist");
        voiceFile.createSync();
      } else {
        voiceQ = base64Encode(voiceFile.readAsBytesSync());
        debugPrint("get" + voiceQ);
      }
    } catch (e) {
      debugPrint("000000000000");
      print(e);
    }
    voiceSalt = Random().nextInt(100000000).toString();
    voiceSign = md5
        .convert(
            utf8.encode(APP_KEY_VOICE + voiceQ + voiceSalt + APP_SECRET_VOICE))
        .toString();
    voicePragma = {
      "q": voiceQ,
      "langType": "zh-CHS",
      "appKey": APP_KEY_VOICE,
      "salt": voiceSalt,
      "sign": voiceSign,
      "format": "wav",
      "rate": "16000 ",
      "channel": "1",
      "type": "1",
    };

    Response response;
    Dio ctjDio = new Dio();
    response = await ctjDio.post(YOUDAO_URL_VOICE, data: voicePragma);
    Map receive = response.data;
    if (response.statusCode == 200) {
      if (receive["errorCode"] == "") {
        textQ = receive["result"];
        Map result = await jaToCnTextResultGet();
        return result;
      } else {
        return "error";
      }
    }
  } catch (e) {}
}

var widthMedia = 0.0;
var heightMedia = 0.0;

class VoiceTranslatePage extends StatefulWidget {
  @override
  _VoiceTranslatePageState createState() => _VoiceTranslatePageState();
}

class _VoiceTranslatePageState extends State<VoiceTranslatePage> {
  String fp;
  double cnSize = 80;
  double jaSize = 80;

  @override
  Widget build(BuildContext context) {
    widthMedia = MediaQuery.of(context).size.width;
    heightMedia = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('中日语音互译'),
        backgroundColor: Color.fromARGB(215, 24, 140, 248),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: heightMedia - 200,
            color: Colors.black12,
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: ListView(
                children: <Widget>[
                  Wrap(
                    children: voiceTranslateView,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: widthMedia,
            height: 1.2,
            color: Colors.black12,
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    width: widthMedia * 0.5,
                    child: Center(
                      child: GestureDetector(
                        child: Container(
                          constraints: BoxConstraints.expand(
                            width: cnSize,
                            height: cnSize,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/Chinese_flag.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        onTapDown: (TapDownDetails details) async {
                          cnSize = 100;
                          setState(() {});
                          debugPrint("Ch_Down");
//                      RecorderWav.startRecorder();
                        },
                        onTapUp: (TapUpDetails details) async {
                          debugPrint("Cn_Up");
                          cnSize = 80.0;
                          voiceTranslateView.insert(
                            0,
                            Container(
                              height: 10,
                              width: widthMedia,
                              color: Colors.transparent,
                            ),
                          );
                          voiceTranslateView.insert(
                            0,
                            CnResultShow(),
                          );
                          print(voiceTranslateView);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: widthMedia * 0.5,
                    child: Center(
                      child: GestureDetector(
                        child: Container(
                          constraints: BoxConstraints.expand(
                            width: jaSize,
                            height: jaSize,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/Japanese_flag.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                            border: Border.all(
                                color: Color.fromARGB(255, 254, 0, 0),
                                width: 1.4),
                          ),
                        ),
                        onTapDown: (TapDownDetails details) {
                          debugPrint("Jap_Down");
                          jaSize = 100;
                          setState(() {});
                        },
                        onTapUp: (TapUpDetails details) {
                          debugPrint("Jap_Up");
                          jaSize = 80;
                          voiceTranslateView.insert(
                            0,
                            Container(
                              height: 10,
                              width: widthMedia,
                              color: Colors.transparent,
                            ),
                          );
                          voiceTranslateView.insert(
                            0,
                            JaResultShow(),
                          );
                          print(voiceTranslateView);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CnResultShow extends StatefulWidget {
  @override
  _CnResultShowState createState() => _CnResultShowState();
}

class _CnResultShowState extends State<CnResultShow> {
  int changeNum = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthMedia,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Container(
                  constraints: BoxConstraints.expand(
                    width: 40,
                    height: 40,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/Chinese_flag.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                        color: Color.fromARGB(255, 254, 0, 0), width: 1.4),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
                child: Container(
                  width: widthMedia - 100,
                  child: Text(
                    "这个东西多少钱？",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: widthMedia - 50,
              height: 1.0,
              color: Colors.black38,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 7.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: widthMedia - 107,
                  child: Text(
                    "これはいくらですか。？",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.graphic_eq,
                    color: Colors.black54,
                  ),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    soundOut(ctjReceiveData["tSpeakUrl"]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JaResultShow extends StatefulWidget {
  @override
  _JaResultShowState createState() => _JaResultShowState();
}

class _JaResultShowState extends State<JaResultShow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthMedia,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Container(
                  constraints: BoxConstraints.expand(
                    width: 40,
                    height: 40,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/Japanese_flag.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                        color: Color.fromARGB(255, 254, 0, 0), width: 1.4),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
                child: Container(
                  width: widthMedia - 100,
                  child: Text(
                    "こんにちは。",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: widthMedia - 50,
              height: 1.0,
              color: Colors.black38,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 7.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: widthMedia - 107,
                  child: Text(
                    "你好。",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.graphic_eq,
                    color: Colors.black54,
                  ),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    soundOut(jtcReceiveData["tSpeakUrl"]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
