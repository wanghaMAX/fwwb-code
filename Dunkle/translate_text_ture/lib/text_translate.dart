import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'flutterSound.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color colorThePage = Color.fromARGB(255, 19, 229, 99);

var widthMedia = 0.0;
var heightMedia = 0.0;

final String YOUDAO_URL = "http://openapi.youdao.com/api";
final String APP_KEY = "705ca7cd1e9cce30";
final String APP_SECRET = "Rt2TwJG13WTaAHhJoQXOHqVgFXUVMUv7";

String q = "";
String curtime;
String salt;
String SIGN;
String sign;
Map<String, String> pragma;

var ctjReceiveData;
var jtcReceiveData;

var textTranslateSoundController = FlutterSound();

int changeNum = 0;
String playResult = '';
SharedPreferences prefs;
List<String> historySave = List();

cnToJaResultGet() async {
  try {
    salt = Random().nextInt(100000000).toString();
    curtime =
        ((DateTime.now().millisecondsSinceEpoch / 1000).round()).toString();
    if (q.length <= 20) {
      SIGN = APP_KEY + q + salt + curtime + APP_SECRET;
      sign = sha256.convert(utf8.encode(SIGN)).toString();
    } else {
      SIGN = APP_KEY +
          q.substring(0, 10) +
          q.length.toString() +
          q.substring(q.length - 10, q.length) +
          salt +
          curtime +
          APP_SECRET;
      sign = sha256.convert(utf8.encode(SIGN)).toString();
    }
    pragma = {
      "q": q,
      "from": "zh-CHS",
      "to": "ja",
      "voice": "0",
      "appKey": APP_KEY,
      "salt": salt,
      "curtime": curtime,
      "sign": sign,
      "signType": "v3"
    };

    Response response;
    Dio ctjDio = new Dio();
    response = await ctjDio.get(YOUDAO_URL, queryParameters: pragma);
    Map receive = response.data;
    if (response.statusCode == 200) {
      return receive;
    }
  } catch (e) {}
}

jaToCnResultGet() async {
  try {
    salt = Random().nextInt(100000000).toString();
    curtime =
        ((DateTime.now().millisecondsSinceEpoch / 1000).round()).toString();
    if (q.length <= 20) {
      SIGN = APP_KEY + q + salt + curtime + APP_SECRET;
      sign = sha256.convert(utf8.encode(SIGN)).toString();
    } else {
      SIGN = APP_KEY +
          q.substring(0, 10) +
          q.length.toString() +
          q.substring(q.length - 10, q.length) +
          salt +
          curtime +
          APP_SECRET;
      sign = sha256.convert(utf8.encode(SIGN)).toString();
    }
    pragma = {
      "q": q,
      "from": "ja",
      "to": "zh-CHS",
      "voice": "0",
      "appKey": APP_KEY,
      "salt": salt,
      "curtime": curtime,
      "sign": sign,
      "signType": "v3"
    };

    Response response;
    Dio jtcDio = new Dio();
    response = await jtcDio.get(YOUDAO_URL, queryParameters: pragma);
    if (response.statusCode == 200) {
      return response.data;
    }
  } catch (e) {}
}

class TextTranslatePage extends StatefulWidget {
  @override
  _TextTranslatePageState createState() => _TextTranslatePageState();
}

class _TextTranslatePageState extends State<TextTranslatePage>
    with SingleTickerProviderStateMixin {
  TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);
    setData()async {
      prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < 20; i++) {
        if (prefs.getString("historyInput$i") != null) {
          if (prefs.getString("historyOutput$i") != null) {
            historySave.add(prefs.getString("historyInput$i"));
            historySave.add(prefs.getString("historyOutput$i"));
          }
        }
      }
    }
    setData();
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widthMedia = MediaQuery.of(context).size.width;
    heightMedia = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: colorThePage,
          leading: FlatButton(
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: (){
              setData()async{
                prefs = await SharedPreferences.getInstance();
                int historyNum = 0;
                for(String historyText in historySave){
                  await prefs.setString("history$historyNum", historyText);
                  print(prefs.getString("history$historyNum"));
                  historyNum ++;
                }
                Navigator.pop(context);
              }
              setData();
            },
          ),
          elevation: 0.0,
          centerTitle: true,
          title: Text('中日文本互译'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '历史',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white70,
                ),
              ),
              onPressed: () {
                setData()async{
                  prefs = await SharedPreferences.getInstance();
                  int historyNum = 0;
                  for(String historyText in historySave){
                    if(historyNum%2 == 0){
                      int a = (historyNum/2).round();
                      await prefs.setString("historyInput$a", historyText);
                    }else{
                      int a = ((historyNum-1)/2).round();
                      await prefs.setString("historyOutput$a", historyText);
                    }
                    historyNum ++;
                  }
                  print(historySave);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TextTranslateHistory()));
                }
                setData();
              },
            )
          ],
          bottom: PreferredSize(
              child: Container(
                height: heightMedia * 0.06,
                width: widthMedia,
                child: Center(
                  child: TabBar(
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    controller: _tabBarController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '中文',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Icon(
                              Icons.navigate_next,
                              size: 24.0,
                            ),
                            Text(
                              '日文',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '日文',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Icon(
                              Icons.navigate_next,
                              size: 24.0,
                            ),
                            Text(
                              '中文',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            preferredSize: Size.fromHeight(heightMedia*0.13),
          ),
        ),
        preferredSize: Size.fromHeight(heightMedia*0.13),
      ),
      body: TabBarView(
        controller: _tabBarController,
        children: <Widget>[
          CnToJaTextPage(),
          JaToCnTextPage(),
        ],
      ),
      resizeToAvoidBottomPadding: true,
    );
  }
}

class CnToJaTextPage extends StatefulWidget {
  @override
  _CnToJaTextPageState createState() => _CnToJaTextPageState();
}

class _CnToJaTextPageState extends State<CnToJaTextPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var _cnToJaOutputController = TextEditingController();
  var _cnToJaInputController = TextEditingController();

  @override
  void dispose() {
    _cnToJaOutputController.dispose();
    _cnToJaInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: TextField(
            controller: _cnToJaInputController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: '请输入需要翻译的中文',
              hintStyle: TextStyle(color: Colors.black12, fontSize: 20.0),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              contentPadding: const EdgeInsets.all(10.0),
            ),
            maxLines: 8,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.0,
            ),
            onEditingComplete: () {
              changeNum = 2;
              FocusScope.of(context).requestFocus(FocusNode());
              if (_cnToJaInputController.text.isNotEmpty) {
                if (q != _cnToJaInputController.text) {
                  q = _cnToJaInputController.text;
                  setData() async {
                    ctjReceiveData = await cnToJaResultGet();
                    if (ctjReceiveData["errorCode"] == "0") {
                      _cnToJaOutputController.text =
                          ctjReceiveData["translation"][0];
                      if(historySave.length >= 20){
                        historySave.removeAt(0);
                        historySave.removeAt(1);
                      }
                      historySave.add(_cnToJaInputController.text);
                      historySave.add(_cnToJaOutputController.text);
                    } else {}
                  }

                  setData();
                }
              } else {
                _cnToJaOutputController.text = '';
                q = '';
                ctjReceiveData["tSpeakUrl"] = '';
              }
            },
          ),
        ),
        Icon(
          Icons.expand_more,
          size: 30.0,
          color: colorThePage,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
          child: TextField(
            controller: _cnToJaOutputController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: '此处显示翻译结果',
              hintStyle: TextStyle(color: Colors.black12, fontSize: 20.0),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              contentPadding: const EdgeInsets.all(10.0),
            ),
            maxLines: 8,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.0,
            ),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 38.0,
              width: 107.0,
              child: RaisedButton(
                elevation: 0.0,
                color: colorThePage,
                child: Text(
                  '清空输入',
                  style: TextStyle(color: Colors.white, fontSize: 18.6),
                ),
                onPressed: () {
                  _cnToJaInputController.text = '';
                  _cnToJaOutputController.text = '';
                  q = '';
                  ctjReceiveData["tSpeakUrl"] = '';
                }
              ),
            ),
            SizedBox(
              height: 38.0,
              width: 107.0,
              child: RaisedButton(
                elevation: 0.0,
                color: colorThePage,
                child: Icon(
                  Icons.audiotrack,
                  size: 25.4,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (ctjReceiveData["tSpeakUrl"].toString().isNotEmpty) {
                    if (changeNum % 2 == 0) {
                      textTranslateSoundController
                          .startPlayer(ctjReceiveData["tSpeakUrl"]);
                    } else {
                      if (textTranslateSoundController.isPlaying) {
                        textTranslateSoundController.stopPlayer();
                      } else {
                        textTranslateSoundController
                            .startPlayer(ctjReceiveData["tSpeakUrl"]);
                        changeNum++;
                      }
                    }
                    changeNum++;
                  }
                }
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class JaToCnTextPage extends StatefulWidget {
  @override
  _JaToCnTextPageState createState() => _JaToCnTextPageState();
}

class _JaToCnTextPageState extends State<JaToCnTextPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var _jaToCnInputController = TextEditingController();
  var _jaToCnOutputController = TextEditingController();

  @override
  void dispose() {
    _jaToCnInputController.dispose();
    _jaToCnOutputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: TextField(
            controller: _jaToCnInputController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'あなたが翻訳する日本語を入力してください',
              hintStyle: TextStyle(color: Colors.black12, fontSize: 20.0),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              contentPadding: const EdgeInsets.all(10.0),
            ),
            maxLines: 8,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.0,
            ),
            onEditingComplete: () {
              changeNum = 2;
              FocusScope.of(context).requestFocus(FocusNode());
              if (_jaToCnInputController.text.isNotEmpty) {
                if (q != _jaToCnInputController.text) {
                  q = _jaToCnInputController.text;
                  setData() async {
                    jtcReceiveData = await jaToCnResultGet();
                    if (jtcReceiveData["errorCode"] == "0") {
                      _jaToCnOutputController.text =
                          jtcReceiveData["translation"][0];
                      if(historySave.length >= 20){
                        historySave.removeAt(0);
                        historySave.removeAt(1);
                      }
                      historySave.add(_jaToCnInputController.text);
                      historySave.add(_jaToCnOutputController.text);
                    } else {}
                  }

                  setData();
                }
              } else {
                _jaToCnOutputController.text = '';
                q = '';
                jtcReceiveData["tSpeakUrl"] = '';
              }
            },
          ),
        ),
        Icon(
          Icons.expand_more,
          size: 30.0,
          color: colorThePage,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
          child: TextField(
            controller: _jaToCnOutputController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'ここに、翻訳結果を表示する',
              hintStyle: TextStyle(color: Colors.black12, fontSize: 20.0),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              contentPadding: const EdgeInsets.all(10.0),
            ),
            maxLines: 8,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.0,
            ),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 37.0,
              width: 107.0,
              child: RaisedButton(
                elevation: 0.0,
                color: colorThePage,
                child: Text(
                  '清空输入',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                onPressed: () {
                  _jaToCnInputController.text = '';
                  _jaToCnOutputController.text = '';
                  q = '';
                  jtcReceiveData["tSpeakUrl"] = '';
                }
              ),
            ),
            SizedBox(
              height: 37.0,
              width: 107.0,
              child: RaisedButton(
                elevation: 0.0,
                color: colorThePage,
                child: Icon(
                  Icons.audiotrack,
                  size: 25.4,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (jtcReceiveData["tSpeakUrl"].toString().isNotEmpty) {
                    if (changeNum % 2 == 0) {
                      textTranslateSoundController
                          .startPlayer(jtcReceiveData["tSpeakUrl"]);
                    } else {
                      if (textTranslateSoundController.isPlaying) {
                        textTranslateSoundController.stopPlayer();
                      } else {
                        textTranslateSoundController
                            .startPlayer(jtcReceiveData["tSpeakUrl"]);
                        changeNum++;
                      }
                    }
                    changeNum++;
                  }
                }),
            ),
          ],
        ),
      ],
    );
  }
}

class TextTranslateHistory extends StatefulWidget {
  @override
  _TextTranslateHistoryState createState() => _TextTranslateHistoryState();
}

class _TextTranslateHistoryState extends State<TextTranslateHistory> {
  List<Widget> historyTile = List();

  @override
  Widget build(BuildContext context) {
    for(int i = 0; i< 20; i++){
      print(prefs.getString("historyInput$i"));
      print(prefs.getString("historyOutput$i"));
      if(prefs.getString("historyInput$i") != null){
        if( prefs.getString("historyOutput$i") != null){
          print("4444444444444444444444444444444444");
          historyTile.insert(0,
            Container(
              color: Colors.white,
              child: ExpansionTile(
                leading: Icon(Icons.autorenew,size: 25.0,),
                title: Text(prefs.getString("historyInput$i"),style: TextStyle(fontSize: 20.0),),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text(prefs.getString("historyOutput$i"),style: TextStyle(fontSize: 20.0),),
                  ),
                ],
              ),
            ),
          );
          historyTile.insert(0,
            Container(
              color: Colors.transparent,
              height: 10.0,
            ),
          );
        }
      }
    }
    historyTile.add(
      Container(
        color: Colors.transparent,
        height: 10.0,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('历史'),
        backgroundColor: colorThePage,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.black12,
        width: widthMedia,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0.0, 10, 0),
          child: Container(
            color: Colors.transparent,
            child:  ListView(
              children: historyTile,
            ),
          ),

        ),
      ),
    );
  }
}
